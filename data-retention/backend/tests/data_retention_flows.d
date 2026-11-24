/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the retention workflow
/// through the ports (seed → end-of-purpose check → deletion requests →
/// archiving and destruction), the business rules of the maintenance, the
/// REST API and the OData endpoint over vibe.d test requests, the built-in
/// JWT login, and the batching file store.
module tests.data_retention_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.data_retention;

@safe:

version (unittest) {
  /// 2026-11-24T00:00:00Z — every test runs on the same day.
  long t0() {
    return parseIsoTime("2026-11-24");
  }

  DrContainer newContainer(IClock clock = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["workerIntervalSeconds"] = 5; // requests stay pending, jobs wait (no worker runs in tests)
    auto c = new DrContainer(loadDrConfig(o, "/nonexistent"), storage, clock !is null ? clock : new ManualClock(t0));
    c.events.log = false;
    return c;
  }

  /// One HTTP call through the router; text bodies are sent as is.
  Json call(URLRouter router, string method, string path, Json body, out int status, string contentType = "application/json",
    string text = "", string bearer = "") @trusted {
    InetHeaderMap headers;
    headers["Content-Type"] = contentType;
    if (bearer.length)
      headers["Authorization"] = "Bearer " ~ bearer;
    auto payload = text.length ? text : body.type == Json.Type.undefined ? "" : body.toString;
    auto req = createTestHTTPServerRequest(URL("http://localhost" ~ path), httpMethodFromString(method), headers,
      createMemoryStream(cast(ubyte[]) payload.dup, false));
    auto output = createMemoryOutputStream();
    auto res = createTestHTTPServerResponse(output, null, TestHTTPResponseMode.bodyOnly);
    router.handleRequest(req, res);
    status = res.statusCode;
    auto answer = cast(string) output.data;
    if (answer.strip.length == 0)
      return Json(null);
    try
      return parseJsonString(answer);
    catch (Exception)
      return Json(answer);
  }

  URLRouter openRouter(DrContainer c) {
    c.engine.enforceScopes = c.security.requireAuthentication; // as in app.d
    auto router = new URLRouter;
    new DrHealthController(c.config, c.security.mode).registerRoutes(router, c.config.apiPath);
    new AuthController(c.ports, c.security).registerRoutes(router);
    new DrApiController(c.engine, c.security).registerRoutes(router);
    auto odata = new ODataController(c.engine, "/odata/v4/data-retention");
    odata.verifier = c.security.verifier;
    odata.requireAuthentication = c.security.requireAuthentication;
    odata.registerRoutes(router);
    return router;
  }

  auto t = TenantId("default");
  auto admin = UserId("admin");

  DataSubject subject(DrContainer c, string id) {
    return c.ports.dataSubjects.get(t, DataSubjectId(id));
  }
}

/// The retention workflow through the driving ports.
unittest {
  auto c = newContainer();
  auto seeded = seedDemoData(c.ports, c.clock, t, admin);
  assert(seeded.applicationGroups == 3 && seeded.businessPurposes == 4 && seeded.legalGrounds == 6, seeded.to!string);
  assert(seeded.residenceRules == 5 && seeded.retentionRules == 4 && seeded.dataSubjects == 12 && seeded.archivingJobs == 2);

  // evaluation: the longest legal obligation governs
  auto grace = subject(c, "ds-1003");
  assert(grace.evaluation.phase == RetentionPhase.withinRetention && grace.evaluation.governingLegalGroundId.value == "sales-tax",
    grace.evaluation.to!string);
  assert(grace.evaluation.endOfRetention == plusYears(plusYears(plusMonths(t0, -30), 1), 10));
  assert(subject(c, "ds-1001").evaluation.phase == RetentionPhase.withinResidence); // business ongoing
  assert(subject(c, "ds-1005").evaluation.phase == RetentionPhase.endOfRetention);

  auto stats = c.ports.statistics.compute(t);
  assert(stats.dataSubjects == 12 && stats.activeSubjects == 12 && stats.legalHolds == 1, stats.to!string);
  assert(stats.dueForBlocking == 8 && stats.dueForDestruction == 4 && stats.pendingRequests == 2, stats.to!string);
  assert(stats.activeBusinessPurposes == 3 && stats.scheduledJobs == 2 && stats.nextEndOfRetention > t0);

  // simulation changes nothing
  EndOfPurposeCheckRequest check;
  check.tenantId = t;
  check.actor = admin;
  check.simulate = true;
  auto simulated = c.ports.checks.checkEndOfPurpose(check);
  assert(simulated.checked == 12 && simulated.blocked == 4 && simulated.markedForDeletion == 4 && simulated.legalHolds == 1,
    simulated.to!string);
  assert(simulated.withinResidence == 4 && simulated.withinRetention == 3 && simulated.endOfRetention == 5);
  assert(subject(c, "ds-1003").lifecycleStatus == LifecycleStatus.active);

  // the real check blocks and marks
  check.simulate = false;
  auto result = c.ports.checks.checkEndOfPurpose(check);
  assert(result.blocked == 4 && result.markedForDeletion == 4, result.to!string);
  assert(result.blockedSubjects.canFind("ds-1006") && result.markedSubjects.canFind("ds-3002"));
  assert(subject(c, "ds-1003").lifecycleStatus == LifecycleStatus.blocked && subject(c, "ds-1003").blockedAt == t0);
  assert(subject(c, "ds-1005").lifecycleStatus == LifecycleStatus.markedForDeletion);
  assert(subject(c, "ds-1006").lifecycleStatus == LifecycleStatus.blocked); // legal hold: blocked, not marked
  assert(subject(c, "ds-1002").lifecycleStatus == LifecycleStatus.active);
  assert(c.ports.checks.checkEndOfPurpose(check).blocked == 0); // idempotent

  // deletion requests: consent based data is erased, a tax law obligation wins
  auto run = c.ports.deletionRequests.processPending(t, admin);
  assert(run.started == 2 && run.completed == 1 && run.rejected == 1, run.to!string);
  auto erased = c.ports.deletionRequests.get(t, DeletionRequestId("dr-1"));
  assert(erased.status == DeletionRequestStatus.completed, erased.to!string);
  auto tim = subject(c, "ds-3001");
  assert(tim.isDeleted && tim.displayName == "" && tim.externalId == "deleted-ds-3001" && tim.deletionMethod == "delete");
  auto refused = c.ports.deletionRequests.get(t, DeletionRequestId("dr-2"));
  assert(refused.status == DeletionRequestStatus.rejected && refused.earliestDeletionAt == subject(c,
      "ds-1004").evaluation.endOfRetention, refused.to!string);
  assert(refused.resultMessage.canFind("Commercial and tax law retention"));
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.deletionRequests.process(t, DeletionRequestId("dr-2"), admin); }));

  // a new request: one pending per subject, destroyed subjects take none
  CreateDeletionRequestCommand req;
  req.tenantId = t;
  req.actor = admin;
  req.dataSubjectId = DataSubjectId("ds-1002");
  req.action = "block";
  auto blockRequest = c.ports.deletionRequests.create(req);
  assert(failsWith(DrErrorKind.conflict, () { c.ports.deletionRequests.create(req); }));
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.deletionRequests.remove(t, blockRequest.id, admin); }));
  assert(c.ports.deletionRequests.process(t, blockRequest.id, admin).status == DeletionRequestStatus.completed);
  assert(subject(c, "ds-1002").lifecycleStatus == LifecycleStatus.blocked);
  req.dataSubjectId = DataSubjectId("ds-3001");
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.deletionRequests.create(req); }));

  // the ERP job archives blocked subjects and destroys expired ones (legal hold skipped)
  auto job = c.ports.archivingJobs.run(t, ArchivingJobId("job-erp-destruct"), admin);
  assert(job.status == JobStatus.completed && job.selected == 4 && job.destroyed == 1 && job.archived == 2 && job.skipped == 1,
    job.to!string);
  auto barbara = subject(c, "ds-1005");
  assert(barbara.isDeleted && barbara.deletionMethod == "anonymize" && barbara.externalId == "anonymized-ds-1005");
  assert(subject(c, "ds-1003").lifecycleStatus == LifecycleStatus.archived);
  assert(subject(c, "ds-1006").lifecycleStatus == LifecycleStatus.blocked && !subject(c, "ds-1006").isDeleted);
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.archivingJobs.run(t, job.id, admin); }));

  // the CRM dry run counts but changes nothing
  auto dry = c.ports.archivingJobs.run(t, ArchivingJobId("job-crm-dryrun"), admin);
  assert(dry.status == JobStatus.completed && dry.destroyed == 2 && dry.log[0].canFind("would be"), dry.to!string);
  assert(subject(c, "ds-3002").lifecycleStatus == LifecycleStatus.markedForDeletion);

  // a scheduled destruction job runs when it is due
  CreateArchivingJobCommand destruct;
  destruct.tenantId = t;
  destruct.actor = admin;
  destruct.applicationGroupId = ApplicationGroupId("hr");
  destruct.operation = "destruct";
  destruct.scheduledAt = plusDays(t0, 2);
  auto hrJob = c.ports.archivingJobs.create(destruct);
  assert(c.ports.archivingJobs.runDue(t, admin).started == 0);
  (cast(ManualClock) c.clock).advance(3 * 86_400);
  assert(c.ports.archivingJobs.runDue(t, admin).completed == 1);
  assert(c.ports.archivingJobs.get(t, hrJob.id).destroyed == 1 && subject(c, "ds-2003").isDeleted);

  // releasing the legal hold lets the next check mark the subject
  c.ports.dataSubjects.setLegalHold(t, DataSubjectId("ds-1006"), false, "", admin);
  check.applicationGroupId = ApplicationGroupId("erp");
  assert(c.ports.checks.checkEndOfPurpose(check).markedForDeletion == 1);

  auto after = c.ports.statistics.compute(t);
  assert(after.deletedSubjects == 3 && after.archivedSubjects == 2 && after.legalHolds == 0, after.to!string);
}

/// Maintenance rules of purposes, legal grounds, rules and master data.
unittest {
  auto c = newContainer();
  seedDemoData(c.ports, c.clock, t, admin);

  // activation needs a legal ground with a residence rule
  assert(failsWith(DrErrorKind.ruleViolation, () {
      c.ports.businessPurposes.activate(t, BusinessPurposeId("vendors"), admin);
    }));
  c.ports.residenceRules.create(createCommand(t, admin, "", ResidenceRuleInput("", "vendor-contract", 2, "years")));
  assert(c.ports.businessPurposes.activate(t, BusinessPurposeId("vendors"), admin).isActive);
  assert(failsWith(DrErrorKind.conflict, () {
      c.ports.residenceRules.create(createCommand(t, admin, "", ResidenceRuleInput("", "vendor-contract", 1, "years")));
    }));
  assert(failsWith(DrErrorKind.invalid, () { // the legal ground belongs to another purpose
      c.ports.retentionRules.create(createCommand(t, admin, "", RetentionRuleInput("sales", "vendor-contract", 1, "years")));
    }));

  // an active purpose keeps a complete legal ground
  auto vendorRule = c.ports.residenceRules.list(t).find!(r => r.legalGroundId.value == "vendor-contract").front;
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.residenceRules.remove(t, vendorRule.id, admin); }));
  assert(failsWith(DrErrorKind.ruleViolation, () {
      c.ports.residenceRules.update(updateCommand(t, admin, vendorRule.id.value, ResidenceRuleInput("", "", 0, "", false), "active"));
    }));
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.businessPurposes.remove(t, BusinessPurposeId("vendors"), admin); }));

  // immutable references
  assert(failsWith(DrErrorKind.invalid, () {
      c.ports.residenceRules.update(updateCommand(t, admin, vendorRule.id.value, ResidenceRuleInput("", "sales-tax"), "legalGroundId"));
    }));

  // a changed rule takes effect at once (nothing stale)
  auto before = subject(c, "ds-1003").evaluation.endOfRetention;
  auto taxRule = c.ports.retentionRules.get(t, RetentionRuleId("sales-tax-retention"));
  c.ports.retentionRules.update(updateCommand(t, admin, taxRule.id.value, RetentionRuleInput("", "", 12), "duration"));
  assert(subject(c, "ds-1003").evaluation.endOfRetention == plusYears(before, 2));

  // master data in use cannot be deleted; a deactivated purpose without subjects can
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.applicationGroups.remove(t, ApplicationGroupId("erp"), admin); }));
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.dataSubjectRoles.remove(t, DataSubjectRoleId("vendor"), admin); }));
  c.ports.businessPurposes.deactivate(t, BusinessPurposeId("vendors"), admin);
  c.ports.businessPurposes.remove(t, BusinessPurposeId("vendors"), admin);
  assert(c.ports.legalGrounds.list(t).all!(g => g.businessPurposeId.value != "vendors")); // cascaded
  assert(c.ports.residenceRules.list(t).all!(r => r.businessPurposeId.value != "vendors"));
  c.ports.dataSubjectRoles.remove(t, DataSubjectRoleId("vendor"), admin);

  // data subjects: defaults from the purpose, unique external id, no future reference date
  auto created = c.ports.dataSubjects.create(createCommand(t, admin, "ds-9", DataSubjectInput("C-9", "Hedy Lamarr", "", "",
      "sales", "", "", "2026-01-15")));
  assert(created.applicationGroupId.value == "erp" && created.dataSubjectRoleId.value == "customer"
      && created.legalEntityId.value == "de01");
  assert(created.evaluation.phase == RetentionPhase.withinResidence);
  assert(failsWith(DrErrorKind.conflict, () {
      c.ports.dataSubjects.create(createCommand(t, admin, "", DataSubjectInput("C-9", "", "", "", "sales")));
    }));
  assert(failsWith(DrErrorKind.invalid, () {
      c.ports.dataSubjects.create(createCommand(t, admin, "", DataSubjectInput("C-10", "", "", "", "sales", "", "", "2099-01-01")));
    }));
  assert(failsWith(DrErrorKind.invalid, () { // legal ground of another purpose
      c.ports.dataSubjects.create(createCommand(t, admin, "", DataSubjectInput("C-11", "", "", "", "sales", "emp-payroll")));
    }));
  // restricted to one legal ground: the contract rules govern
  auto only = c.ports.dataSubjects.update(updateCommand(t, admin, "ds-9", DataSubjectInput("", "", "", "", "", "sales-contract"),
      "legalGroundId"));
  assert(only.evaluation.governingLegalGroundId.value == "sales-contract");

  // deprecated purposes take no new subjects; destroyed subjects are frozen
  c.ports.businessPurposes.deprecate(t, BusinessPurposeId("marketing"), admin);
  assert(failsWith(DrErrorKind.ruleViolation, () {
      c.ports.dataSubjects.create(createCommand(t, admin, "", DataSubjectInput("M-9", "", "", "", "marketing")));
    }));
  assert(subject(c, "ds-3002").evaluation.phase == RetentionPhase.endOfRetention); // deprecated still governs
  c.ports.deletionRequests.create(CreateDeletionRequestCommand(t, admin, "", DataSubjectId("ds-3002"), "anonymize"));
  c.ports.deletionRequests.processPending(t, admin);
  assert(failsWith(DrErrorKind.ruleViolation, () {
      c.ports.dataSubjects.update(updateCommand(t, admin, "ds-3002", DataSubjectInput("", "New Name"), "displayName"));
    }));
  assert(failsWith(DrErrorKind.ruleViolation, () {
      c.ports.dataSubjects.remove(t, DataSubjectId("ds-1006"), admin); // legal hold
    }));
  assert(failsWith(DrErrorKind.notFound, () {
      c.ports.dataSubjects.create(createCommand(t, admin, "", DataSubjectInput("X-1", "", "", "", "nope")));
    }));
}

/// REST API and OData endpoint.
unittest {
  auto c = newContainer();
  auto router = openRouter(c);
  int status;

  auto health = call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200 && health["status"].get!string == "UP" && health["security"].get!string == "open");
  auto seeded = call(router, "POST", "/api/v1/data-retention/demo-data", Json.emptyObject, status);
  assert(status == 200 && seeded["dataSubjects"].get!long == 12, seeded.toString);
  call(router, "POST", "/api/v1/data-retention/demo-data", Json.emptyObject, status);
  assert(status == 409);

  // legacy CRUD paths
  auto purposes = call(router, "GET", "/api/v1/data-retention/business-purposes?$orderby=name", Json.undefined, status);
  assert(status == 200 && purposes["count"].get!long == 4 && purposes["resources"][0]["name"].get!string == "Employment Administration",
    purposes.toString);
  auto sales = call(router, "GET", "/api/v1/data-retention/business-purposes/sales", Json.undefined, status);
  assert(status == 200 && sales["completeLegalGrounds"].get!long == 2 && sales["rulesText"].get!string.canFind("10 years"));
  auto group = call(router, "POST", "/api/v1/data-retention/application-groups", Json(["id": Json("dms"),
      "name": Json("Documents"), "scope": Json("local"), "applicationIds": Json([Json("DMS")])]), status);
  assert(status == 201 && group["scope"].get!string == "local" && group["dataSubjectCount"].get!long == 0, group.toString);
  auto patched = call(router, "PUT", "/api/v1/data-retention/application-groups/dms", Json(["description": Json("Archive")]), status);
  assert(status == 200 && patched["description"].get!string == "Archive" && patched["name"].get!string == "Documents");
  call(router, "DELETE", "/api/v1/data-retention/application-groups/dms", Json.undefined, status);
  assert(status == 204);
  call(router, "GET", "/api/v1/data-retention/application-groups/dms", Json.undefined, status);
  assert(status == 404);
  auto bad = call(router, "POST", "/api/v1/data-retention/application-groups", Json.undefined, status, "application/json", "{broken");
  assert(status == 400 && "error" in bad);
  call(router, "POST", "/api/v1/data-retention/application-groups", Json(["id": Json("x"), "name": Json("X"),
      "scope": Json("galactic")]), status);
  assert(status == 400);
  call(router, "DELETE", "/api/v1/data-retention/application-groups/erp", Json.undefined, status);
  assert(status == 422);

  // operations
  call(router, "POST", "/api/v1/data-retention/business-purposes/vendors/activate", Json.emptyObject, status);
  assert(status == 422);
  auto evaluation = call(router, "GET", "/api/v1/data-retention/data-subjects/ds-1003/evaluation", Json.undefined, status);
  assert(status == 200 && evaluation["phase"].get!string == "withinRetention" && evaluation["dueForBlocking"].get!bool,
    evaluation.toString);
  auto simulated = call(router, "POST", "/api/v1/data-retention/simulate", Json(["businessPurposeId": Json("employment"),
      "referenceDate": Json("2020-03-31")]), status);
  assert(status == 200 && simulated["endOfPurpose"].get!string == "2021-03-31" && simulated["endOfRetention"].get!string == "2027-03-31",
    simulated.toString);
  auto checked = call(router, "POST", "/api/v1/data-retention/end-of-purpose/check", Json(["applicationGroupId": Json("crm")]), status);
  assert(status == 200 && checked["markedForDeletion"].get!long == 2, checked.toString);
  auto held = call(router, "POST", "/api/v1/data-retention/data-subjects/ds-1002/legal-hold", Json(["reason": Json("Audit")]), status);
  assert(status == 200 && held["legalHold"].get!bool && held["legalHoldReason"].get!string == "Audit");
  auto processed = call(router, "POST", "/api/v1/data-retention/deletion-requests/dr-1/process", Json.emptyObject, status);
  assert(status == 200 && processed["status"].get!string == "completed", processed.toString);
  auto stats = call(router, "GET", "/api/v1/data-retention/statistics", Json.undefined, status);
  assert(status == 200 && stats["deletedSubjects"].get!long == 1 && stats["legalHolds"].get!long == 2, stats.toString);

  // OData
  auto metadata = call(router, "GET", "/odata/v4/data-retention/$metadata", Json.undefined, status);
  assert(status == 200 && metadata.type == Json.Type.string && metadata.get!string.canFind("uim.dataretention"));
  auto due = call(router, "GET", "/odata/v4/data-retention/DataSubjects?$filter=phase eq 'endOfRetention'&$select=id,externalId",
    Json.undefined, status);
  assert(status == 200 && due["value"].length == 5, due.toString); // ds-1005, ds-1006, ds-2003, ds-3002, ds-3003
  auto action = call(router, "POST", "/odata/v4/data-retention/RunArchivingJob", Json(["id": Json("job-crm-dryrun")]), status);
  assert(status == 200 && action["dryRun"].get!bool && action["destroyed"].get!long == 2, action.toString);
  auto created = call(router, "POST", "/odata/v4/data-retention/DataSubjects", Json(["externalId": Json("C-77"),
      "businessPurposeId": Json("sales"), "referenceDate": Json("2025-11-24")]), status);
  assert(status == 201 && created["phase"].get!string == "withinRetention" && created["endOfPurpose"].get!string == "2026-11-24",
    created.toString);
  auto odataStats = call(router, "GET", "/odata/v4/data-retention/Statistics", Json.undefined, status);
  assert(status == 200 && odataStats["dataSubjects"].get!long == 13, odataStats.toString);
}

/// Built-in login (authMode jwt): credentials, lockout, tokens and scopes.
unittest {
  Json[string] o;
  o["storage"] = "memory";
  o["authMode"] = "jwt";
  o["jwtSecret"] = "0123456789abcdef0123456789abcdef";
  o["passwordIterations"] = 1000;
  o["maxFailedLogins"] = 3;
  auto c = new DrContainer(loadDrConfig(o, "/nonexistent"), StorageSetup.init, new ManualClock(t0));
  c.events.log = false;
  assert(c.security.mode == "jwt" && c.security.loginEnabled && !c.security.generatedSecret && !c.engine.enforceScopes);
  assert(c.ports.users.ensureAdministrator(t, "admin", "admin password 1"));
  assert(!c.ports.users.ensureAdministrator(t, "admin", "other password 1"));
  auto router = openRouter(c);
  int status;

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", "/api/v1/data-retention/data-subjects", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/odata/v4/data-retention/DataSubjects", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200); // probes stay public
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);
  call(router, "POST", "/auth/login", Json(["username": Json("ghost"), "password": Json("wrong")]), status);
  assert(status == 401);

  auto login = call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("admin password 1")]), status);
  assert(status == 200 && login["token_type"].get!string == "Bearer" && login["scope"].get!string == "Read Manage Admin", login.toString);
  auto token = login["access_token"].get!string;
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, "application/json", "", token);
  assert(status == 200 && me["user"].get!string == "admin" && me["scopes"].length == 3);
  call(router, "POST", "/api/v1/data-retention/demo-data", Json.emptyObject, status, "application/json", "", token);
  assert(status == 200);

  // an administrator creates a read-only user through OData
  auto created = call(router, "POST", "/odata/v4/data-retention/Users", Json(["id": Json("auditor"),
      "password": Json("auditor password"), "scopes": Json([Json("Read")])]), status, "application/json", "", token);
  assert(status == 201 && created["password"].type == Json.Type.null_ && "passwordHash" !in created, created.toString);
  auto form = call(router, "POST", "/auth/login", Json.undefined, status, "application/x-www-form-urlencoded",
    "username=auditor&password=auditor%20password", "");
  assert(status == 200, form.toString);
  auto auditor = form["access_token"].get!string;
  call(router, "GET", "/odata/v4/data-retention/DataSubjects", Json.undefined, status, "application/json", "", auditor);
  assert(status == 200);
  call(router, "POST", "/odata/v4/data-retention/SimulateRetention", Json(["businessPurposeId": Json("sales"),
      "referenceDate": Json("2024-01-01")]), status, "application/json", "", auditor);
  assert(status == 200); // simulations only need Read
  call(router, "POST", "/odata/v4/data-retention/CheckEndOfPurpose", Json.emptyObject, status, "application/json", "", auditor);
  assert(status == 403);
  call(router, "POST", "/api/v1/data-retention/data-subjects/ds-1003/block", Json.emptyObject, status, "application/json", "", auditor);
  assert(status == 403);
  call(router, "GET", "/odata/v4/data-retention/Users", Json.undefined, status, "application/json", "", auditor);
  assert(status == 403);

  // own password change, then the old one fails
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("auditor password"),
      "newPassword": Json("a better password")]), status, "application/json", "", auditor);
  assert(status == 204);
  call(router, "POST", "/auth/login", Json(["username": Json("auditor"), "password": Json("auditor password")]), status);
  assert(status == 401);

  // lockout after 3 failures, even with the right password
  foreach (_; 0 .. 2)
    call(router, "POST", "/auth/login", Json(["username": Json("auditor"), "password": Json("nope")]), status);
  auto locked = call(router, "POST", "/auth/login", Json(["username": Json("auditor"), "password": Json("a better password")]), status);
  assert(status == 401 && locked["error"]["message"].get!string.canFind("locked"), locked.toString);

  // the last administrator is protected
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.users.deleteUser(t, UserAccountId("admin"), UserId("auditor")); }));
  UpdateUserRequest demote;
  demote.tenantId = t;
  demote.actor = UserId("other");
  demote.id = "admin";
  demote.scopes = ["Read"];
  assert(failsWith(DrErrorKind.ruleViolation, () { c.ports.users.updateUser(demote); }));

  // tampered token
  call(router, "GET", "/api/v1/data-retention/data-subjects", Json.undefined, status, "application/json", "", token[0 .. $ - 2] ~ "xx");
  assert(status == 401);
}

/// Batching file store: an end-of-purpose check writes the snapshot once,
/// a second container (the CLI next to the server) sees the data.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;

  auto path = buildPath(tempDir, "uim-dr-test-" ~ newResourceId(), "data.json");
  scope (exit)
    if (exists(dirName(path)))
      rmdirRecurse(dirName(path));
  auto store = new BatchingFileDocumentStore(path);
  auto first = newContainer(null, StorageSetup(store, store));
  seedDemoData(first.ports, first.clock, t, admin);
  auto before = store.flushes;
  EndOfPurposeCheckRequest check;
  check.tenantId = t;
  check.actor = admin;
  auto result = first.ports.checks.checkEndOfPurpose(check);
  assert(result.blocked + result.markedForDeletion == 8 && store.flushes == before + 1, store.flushes.to!string);

  auto second = newContainer(null, createStorage("file", path));
  assert(second.ports.dataSubjects.list(t).length == 12);
  assert(second.ports.statistics.compute(t).markedForDeletion == 4);
}
