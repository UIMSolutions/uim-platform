/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the quality workflow
/// through the ports (seed → validate → cleanse → resolve duplicates →
/// scorecards), the REST API and the OData endpoint over vibe.d test
/// requests, security, and the batching file store.
module tests.data_quality_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.data_quality;

@safe:

version (unittest) {
  enum long t0 = 639_000_000_000_000_000;

  DqContainer newContainer(IClock clock = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["jobIntervalSeconds"] = 5; // jobs stay pending (no worker runs in tests)
    auto c = new DqContainer(loadDqConfig(o, "/nonexistent"), storage, clock !is null ? clock : new ManualClock(t0));
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

  auto t = TenantId("default");
  auto admin = UserId("admin");
}

/// The quality workflow through the driving ports.
unittest {
  auto c = newContainer();
  auto seeded = seedDemoData(c.ports, t, admin);
  assert(seeded.datasets == 3 && seeded.records == 26 && seeded.validationRules == 10 && seeded.cleansingRules == 8);
  assert(seeded.addresses == 5 && seeded.violations > 10 && seeded.matchGroups >= 2, seeded.to!string);

  auto customers = DatasetId("customers");
  auto before = c.ports.datasets.getDataset(t, customers);
  assert(before.isScored && before.scores.overall < 90, before.scores.to!string);
  assert(c.ports.datasets.getDataset(t, DatasetId("countries")).scores.overall == 100);

  // typical defects were found
  auto violations = c.ports.validation.listViolations(t, customers);
  bool found(string record, string rule) {
    return violations.canFind!(v => v.recordId.value == record && v.ruleId.value == rule);
  }

  assert(found("c-1004", "name-required") && found("c-1003", "email-format") && found("c-1002", "country-iso"));
  assert(found("c-1006", "age-range") && found("c-1007", "postal-de") && found("c-1008", "email-unique"));
  assert(found("c-1005", "status-values"));
  auto statusSuggestion = violations.find!(v => v.ruleId.value == "status-values").front.suggestedValue;
  assert(statusSuggestion == "active", statusSuggestion);

  // the pending cleansing job fixes country names, e-mail case and status values
  auto pending = c.ports.cleansingJobs.listCleansingJobs(t, customers);
  assert(pending.length == 1 && pending[0].status == JobStatus.pending);
  auto job = c.ports.cleansingJobs.runCleansingJob(t, customers, pending[0].id, admin);
  assert(job.status == JobStatus.completed && job.changedRecords >= 5, job.to!string);
  auto c1002 = c.ports.records.getRecord(t, customers, RecordId("c-1002"));
  assert(c1002.field("country") == "DE" && c1002.field("email") == "j.mueller@example.de" && c1002.field("city") == "Berlin");
  assert(c1002.field("countryName") == "Germany");
  auto after = c.ports.datasets.getDataset(t, customers);
  assert(after.scores.accuracy > before.scores.accuracy && after.scores.overall > before.scores.overall,
    before.scores.to!string ~ " → " ~ after.scores.to!string);
  assert(c.ports.scorecards.listSnapshots(t, customers).length >= 2); // trend
  assert(failsWith(DqErrorKind.ruleViolation, () { c.ports.cleansingJobs.cancelCleansingJob(t, customers, job.id, admin); }));

  // resolve a duplicate group with merge: the golden record survives
  CreateCleansingJobRequest dry;
  dry.tenantId = t;
  dry.datasetId = customers;
  dry.dryRun = true;
  auto dryJob = c.ports.cleansingJobs.createCleansingJob(dry);
  assert(dryJob.status == JobStatus.pending);
  dryJob = c.ports.cleansingJobs.runPendingJobs(t).completed == 1 ? c.ports.cleansingJobs.getCleansingJob(t, customers, dryJob.id) : dryJob;
  assert(dryJob.status == JobStatus.completed && dryJob.changedRecords == 0, dryJob.to!string);

  auto groups = c.ports.duplicates.listMatchGroups(t, customers).filter!(g => !g.resolved).array;
  assert(groups.length >= 1);
  auto g = groups.find!(x => x.contains(RecordId("c-1001"))).front;
  assert(g.contains(RecordId("c-1002")));
  auto recordsBefore = c.ports.records.listRecords(t, customers).length;
  ResolveMatchGroupRequest resolve;
  resolve.tenantId = t;
  resolve.actor = admin;
  resolve.datasetId = customers;
  resolve.id = g.id.value;
  resolve.survivorRecordId = "c-1001";
  resolve.merge = true;
  auto resolved = c.ports.duplicates.resolveMatchGroup(resolve);
  assert(resolved.removedRecords == g.size - 1);
  assert(c.ports.records.listRecords(t, customers).length == recordsBefore - resolved.removedRecords);
  assert(c.ports.duplicates.getMatchGroup(t, customers, g.id).resolved);
  assert(failsWith(DqErrorKind.ruleViolation, () { c.ports.duplicates.resolveMatchGroup(resolve); }));

  // records are validated on create and update
  CreateRecordRequest create;
  create.tenantId = t;
  create.actor = admin;
  create.datasetId = customers;
  create.id = "c-2000";
  create.fields = [FieldValue("name", "New Customer"), FieldValue("email", "broken"), FieldValue("country", "DE"),
    FieldValue("postalCode", "10115"), FieldValue("status", "active")];
  auto rec = c.ports.records.createRecord(create);
  assert(rec.isValidated && rec.violationCount == 1 && rec.worstSeverity == "error", rec.to!string);
  UpdateRecordRequest update;
  update.tenantId = t;
  update.datasetId = customers;
  update.id = "c-2000";
  update.merge = true;
  update.fields = [FieldValue("email", "new@example.org")];
  rec = c.ports.records.updateRecord(update);
  assert(rec.violationCount == 0 && rec.qualityScore == 100 && rec.field("name") == "New Customer");
  assert(failsWith(DqErrorKind.conflict, () { c.ports.records.createRecord(create); }));

  // business rules
  assert(failsWith(DqErrorKind.ruleViolation, () { c.ports.datasets.deleteDataset(t, DatasetId("countries"), admin); }));
  assert(failsWith(DqErrorKind.notFound, () { c.ports.validation.validateDataset(t, DatasetId("nope"), admin); }));
  c.ports.datasets.deleteDataset(t, DatasetId("suppliers"), admin);
  assert(c.ports.records.listRecords(t, DatasetId("suppliers")).length == 0);
  assert(c.ports.validation.listViolations(t, DatasetId("suppliers")).length == 0);

  auto stats = c.ports.statistics.compute(t);
  assert(stats.datasets == 2 && stats.addresses == 5 && stats.verifiedAddresses >= 3 && stats.invalidAddresses == 1, stats.to!string);
}

/// Rule maintenance through the OData engine (the path of Fiori, CLI and GUI).
unittest {
  auto c = newContainer();
  auto ctx = RequestContext.local("default", "test", "admin");
  int status(scope void delegate() @safe dg) {
    try
      dg();
    catch (EntitySetException e)
      return e.status;
    return 0;
  }

  c.engine.create(ctx, "Datasets", Json(["id": Json("people"), "name": Json("People")]));
  auto rule = c.engine.create(ctx, "ValidationRules", Json([
      "name": Json("Adult"), "fieldName": Json("age"), "ruleType": Json("range"), "minValue": Json("18"), "status": Json("active")
    ]));
  assert(rule["id"].get!string.length == 16 && rule["dimension"].get!string == "validity");
  auto patched = c.engine.update(ctx, "ValidationRules", rule["id"].get!string, Json(["severity": Json("critical")]));
  assert(patched["severity"].get!string == "critical" && patched["minValue"].get!string == "18");
  assert(status(() { c.engine.update(ctx, "ValidationRules", rule["id"].get!string, Json(["ruleType": Json("bogus")])); }) == 400);

  auto rec = c.engine.create(ctx, "Records", Json(["datasetId": Json("people"), "id": Json("p1"),
      "fields": Json([Json("name=Ada"), Json("age=12")])]));
  assert(rec["key"].get!string == "people~p1" && rec["violationCount"].get!long == 1 && rec["summary"].get!string == "Ada · 12");
  auto page = c.engine.query(ctx, "Violations", ["$filter": "datasetId eq 'people'"]);
  assert(page.rows.length == 1 && page.rows[0]["severity"].get!string == "critical");

  auto imported = c.engine.invoke(ctx, "ImportCsv", Json(["datasetId": Json("people"),
      "csv": Json("id;name;age\np2;Grace;85\np3;Linus;\n")]));
  assert(imported["created"].get!long == 2 && imported["validated"].get!bool);
  auto profile = c.engine.invoke(ctx, "ProfileDataset", Json(["datasetId": Json("people")]));
  assert(profile["columns"].get!long == 2 && profile["records"].get!long == 3);
  auto age = c.engine.read(ctx, "ColumnProfiles", "people~age");
  assert(age["detectedType"].get!string == "integer" && age["missingCount"].get!long == 1);

  auto ds = c.engine.read(ctx, "Datasets", "people");
  assert(ds["recordCount"].get!long == 3 && ds["violationCount"].get!long == 1 && ds["rating"].type == Json.Type.string);
  assert(status(() { c.engine.create(ctx, "Datasets", Json(["id": Json("people")])); }) == 409);
  assert(status(() { c.engine.create(ctx, "Violations", Json(["datasetId": Json("people")])); }) == 501
    || status(() { c.engine.create(ctx, "Violations", Json(["datasetId": Json("people")])); }) >= 400);
  assert(status(() { c.engine.invoke(ctx, "DetectDuplicates", Json(["datasetId": Json("people"), "matchFields": Json("")])); }) == 400);

  auto addr = c.engine.create(ctx, "Addresses", Json(["inputLine1": Json("Hauptstr. 1"), "inputCity": Json("köln"),
      "inputPostalCode": Json("50667"), "inputCountry": Json("Deutschland")]));
  assert(addr["line1"].get!string == "Hauptstraße 1" && addr["country"].get!string == "DE" && addr["quality"].get!string == "corrected");
}

/// REST API and OData over HTTP.
unittest {
  auto c = newContainer();
  seedDemoData(c.ports, t, admin);
  auto security = new SecuritySetup;
  auto router = new URLRouter;
  new DqApiController(c.ports, security).registerRoutes(router);
  new ODataController(c.engine, "/odata/v4/data-quality").registerRoutes(router);
  int status;

  auto meta = call(router, "GET", "/api/v1/meta", Json.undefined, status);
  assert(status == 200 && meta["ruleTypes"].length == 9);

  auto checked = call(router, "POST", "/api/v1/validate", Json(["datasetId": Json("customers"), "records": Json([
      Json(["id": Json("a"), "fields": Json(["name": Json("Ada"), "email": Json("ada@example.org"), "country": Json("GB"),
        "status": Json("active")])]),
      Json(["id": Json("b"), "fieldValues": Json(["email": Json("nope"), "country": Json("XX"), "age": Json(7)])])
    ])]), status);
  assert(status == 200 && checked["valid"].get!long == 1 && checked["invalid"].get!long == 1, checked.toString);
  assert(checked["results"][1]["violations"].length >= 4, checked.toString);

  auto dup = call(router, "POST", "/api/v1/duplicates/detect", Json(["matchFields": Json([Json("name")]), "strategy": Json("fuzzy"),
      "threshold": Json(85), "records": Json([
        Json(["id": Json("1"), "fields": Json(["name": Json("Meyer GmbH")])]),
        Json(["id": Json("2"), "fields": Json(["name": Json("Meier GmbH")])]),
        Json(["id": Json("3"), "fields": Json(["name": Json("Schulz AG")])])
      ])]), status);
  assert(status == 200 && dup["count"].get!long == 1 && dup["groups"][0]["size"].get!long == 2, dup.toString);

  auto prof = call(router, "POST", "/api/v1/profiles", Json(["records": Json([Json(["fields": Json(["n": Json("1")])]),
      Json(["fields": Json(["n": Json("2")])])])]), status);
  assert(status == 200 && prof["columns"][0]["detectedType"].get!string == "integer", prof.toString);

  auto addr = call(router, "POST", "/api/v1/addresses/cleanse", Json(["line1": Json("1600 Pennsylvania Ave NW"),
      "city": Json("washington"), "region": Json("dc"), "postalCode": Json("20500"), "country": Json("USA"),
      "persist": Json(false)]), status);
  assert(status == 200 && addr["results"][0]["country"].get!string == "US", addr.toString);
  assert(c.ports.addresses.listAddresses(t).length == 5); // not stored

  auto imported = call(router, "POST", "/api/v1/datasets/leads/records?createDataset=true", Json.undefined, status, "text/csv",
    "id,name,email\nl1,Lead One,one@example.org\nl2,,two@example\n");
  assert(status == 200 && imported["created"].get!long == 2 && imported["datasetCreated"].get!bool, imported.toString);
  auto card = call(router, "GET", "/api/v1/datasets/leads/scorecard", Json.undefined, status);
  assert(status == 200 && card["records"].get!long == 2 && card["overallScore"].get!double < 100, card.toString);
  auto list = call(router, "GET", "/api/v1/datasets", Json.undefined, status);
  assert(list["count"].get!long == 4);

  call(router, "GET", "/api/v1/datasets/nope/scorecard", Json.undefined, status);
  assert(status == 404);
  auto bad = call(router, "POST", "/api/v1/validate", Json(["nothing": Json(1)]), status);
  assert(status == 400 && "error" in bad);
  call(router, "POST", "/api/v1/validate", Json.undefined, status, "application/json", "{broken");
  assert(status == 400);

  // OData
  auto metadata = call(router, "GET", "/odata/v4/data-quality/$metadata", Json.undefined, status);
  assert(status == 200 && metadata.type == Json.Type.string && metadata.get!string.canFind("uim.dataquality"));
  auto rows = call(router, "GET", "/odata/v4/data-quality/Datasets?$orderby=id&$select=id,overallScore", Json.undefined, status);
  assert(status == 200 && rows["value"].length == 4 && rows["value"][0]["id"].get!string == "countries", rows.toString);
  auto run = call(router, "POST", "/odata/v4/data-quality/ValidateDataset", Json(["datasetId": Json("customers")]), status);
  assert(status == 200 && run["records"].get!long == 12, run.toString);
  auto stats = call(router, "GET", "/odata/v4/data-quality/Statistics", Json.undefined, status);
  assert(status == 200 && stats["datasets"].get!long == 4, stats.toString);
}

/// Security: with authentication required, calls need a token.
unittest {
  import uim.platform.service.infrastructure.security.context : Hs256TokenVerifier;

  auto c = newContainer();
  auto security = new SecuritySetup;
  security.requireAuthentication = true;
  security.verifier = new Hs256TokenVerifier("0123456789abcdef0123456789abcdef");
  auto router = new URLRouter;
  new DqApiController(c.ports, security).registerRoutes(router);
  int status;
  call(router, "GET", "/api/v1/datasets", Json.undefined, status);
  assert(status == 401);
}

/// Batching file store: an import of 500 records writes the snapshot a
/// few times, not 500 times; a second container (the CLI) sees the data.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;

  auto path = buildPath(tempDir, "uim-dq-test-" ~ newResourceId(), "data.json");
  scope (exit)
    if (exists(dirName(path)))
      rmdirRecurse(dirName(path));
  auto store = new BatchingFileDocumentStore(path);
  auto first = newContainer(null, StorageSetup(store, store));
  InlineRecord[] records;
  foreach (i; 0 .. 500)
    records ~= InlineRecord("r" ~ i.to!string, [FieldValue("name", "Name " ~ (i % 450).to!string),
        FieldValue("email", i % 10 == 0 ? "" : "u" ~ i.to!string ~ "@example.org")]);
  ImportRecordsRequest r;
  r.tenantId = t;
  r.actor = admin;
  r.datasetId = DatasetId("bulk");
  r.createDataset = true;
  r.records = records;
  auto result = first.ports.records.importRecords(r);
  assert(result.created == 500 && result.validated);
  assert(store.flushes < 10, store.flushes.to!string);

  auto second = newContainer(null, createStorage("file", path));
  assert(second.ports.records.listRecords(t, DatasetId("bulk")).length == 500);
  assert(second.ports.statistics.compute(t).records == 500);
}

/// Built-in login (authMode jwt): credentials, lockout, tokens and scopes.
unittest {
  Json[string] o;
  o["storage"] = "memory";
  o["authMode"] = "jwt";
  o["jwtSecret"] = "0123456789abcdef0123456789abcdef";
  o["passwordIterations"] = 1000;
  o["maxFailedLogins"] = 3;
  auto c = new DqContainer(loadDqConfig(o, "/nonexistent"));
  c.events.log = false;
  c.engine.enforceScopes = true;
  assert(c.security.mode == "jwt" && c.security.loginEnabled && !c.security.generatedSecret);
  assert(c.ports.users.ensureAdministrator(t, "admin", "admin password 1"));
  assert(!c.ports.users.ensureAdministrator(t, "admin", "other password 1"));

  auto router = new URLRouter;
  new AuthController(c.ports, c.security).registerRoutes(router);
  new DqApiController(c.ports, c.security).registerRoutes(router);
  auto odata = new ODataController(c.engine, "/odata/v4/data-quality");
  odata.verifier = c.security.verifier;
  odata.requireAuthentication = true;
  odata.registerRoutes(router);
  int status;

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", "/api/v1/datasets", Json.undefined, status);
  assert(status == 401);
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);
  call(router, "POST", "/auth/login", Json(["username": Json("ghost"), "password": Json("wrong")]), status);
  assert(status == 401);

  auto login = call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("admin password 1")]), status);
  assert(status == 200 && login["token_type"].get!string == "Bearer" && login["scope"].get!string == "Read Manage Admin", login.toString);
  auto token = login["access_token"].get!string;
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, "application/json", "", token);
  assert(status == 200 && me["user"].get!string == "admin" && me["scopes"].length == 3);
  call(router, "GET", "/api/v1/datasets", Json.undefined, status, "application/json", "", token);
  assert(status == 200);

  // an administrator creates a read-only user through OData
  auto created = call(router, "POST", "/odata/v4/data-quality/Users", Json(["id": Json("viewer"),
      "password": Json("viewer password"), "scopes": Json([Json("Read")])]), status, "application/json", "", token);
  assert(status == 201 && created["password"].type == Json.Type.null_ && "passwordHash" !in created, created.toString);
  auto form = call(router, "POST", "/auth/login", Json.undefined, status, "application/x-www-form-urlencoded",
    "username=viewer&password=viewer%20password", "");
  assert(status == 200, form.toString);
  auto viewer = form["access_token"].get!string;
  call(router, "GET", "/odata/v4/data-quality/Datasets", Json.undefined, status, "application/json", "", viewer);
  assert(status == 200);
  call(router, "POST", "/odata/v4/data-quality/Datasets", Json(["id": Json("x")]), status, "application/json", "", viewer);
  assert(status == 403);
  call(router, "POST", "/api/v1/datasets/x/validate", Json.emptyObject, status, "application/json", "", viewer);
  assert(status == 403);
  call(router, "GET", "/odata/v4/data-quality/Users", Json.undefined, status, "application/json", "", viewer);
  assert(status == 403);

  // own password change, then the old one fails
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("viewer password"),
      "newPassword": Json("a better password")]), status, "application/json", "", viewer);
  assert(status == 204);
  call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("viewer password")]), status);
  assert(status == 401);

  // lockout after 3 failures, even with the right password
  foreach (_; 0 .. 2)
    call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("nope")]), status);
  auto locked = call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("a better password")]), status);
  assert(status == 401 && locked["error"]["message"].get!string.canFind("locked"), locked.toString);

  // the last administrator is protected
  assert(failsWith(DqErrorKind.ruleViolation, () { c.ports.users.deleteUser(t, UserAccountId("admin"), UserId("viewer")); }));
  UpdateUserRequest demote;
  demote.tenantId = t;
  demote.actor = UserId("other");
  demote.id = "admin";
  demote.scopes = ["Read"];
  assert(failsWith(DqErrorKind.ruleViolation, () { c.ports.users.updateUser(demote); }));

  // tampered token
  call(router, "GET", "/api/v1/datasets", Json.undefined, status, "application/json", "", token[0 .. $ - 2] ~ "xx");
  assert(status == 401);
}
