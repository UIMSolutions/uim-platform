/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the guided workflow
/// through the ports (seed → instantiate → tasks → automation → completion),
/// the business rules of scenarios, templates, workflows and tasks, the
/// REST API and the OData endpoint over vibe.d test requests, the built-in
/// JWT login with scopes, the CLI and the batching file store.
module tests.integration_automation_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.integration_automation;

@safe:

version (unittest) {
  /// 2026-11-25T00:00:00Z — every test runs on the same day.
  long t0() {
    return parseIsoTime("2026-11-25");
  }

  IaContainer newContainer(Json[string] extra = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["workerIntervalSeconds"] = 5; // automation runs on demand only (no worker runs in tests)
    o["passwordIterations"] = 1000;
    foreach (k, v; extra)
      o[k] = v;
    auto c = new IaContainer(loadIaConfig(o, "/nonexistent"), storage, new ManualClock(t0));
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

  URLRouter routerOf(IaContainer c) {
    c.engine.enforceScopes = c.security.requireAuthentication; // as in app.d
    auto router = new URLRouter;
    new IaHealthController(c.config, c.security.mode, c.automation.mode, c.connectivity.mode)
      .registerRoutes(router, c.config.apiPath);
    new AuthController(c.ports, c.security).registerRoutes(router);
    new IaApiController(c.engine, c.security).registerRoutes(router);
    auto odata = new ODataController(c.engine, "/odata/v4/integration-automation");
    odata.verifier = c.security.verifier;
    odata.requireAuthentication = c.security.requireAuthentication;
    odata.registerRoutes(router);
    return router;
  }

  auto t = TenantId("default");
  auto actor = UserId("tester");

  WorkflowTask taskNamed(IaContainer c, WorkflowId wf, string name) {
    foreach (task; c.ports.tasks.listOf(t, wf))
      if (task.name == name)
        return task;
    assert(false, "no task " ~ name);
  }


  ScenarioTaskInput templateInput(string scenario, int seq, string name, string type = "manual") {
    ScenarioTaskInput i;
    i.scenarioId = scenario;
    i.sequenceNumber = seq;
    i.name = name;
    i.taskType = type;
    if (type == "automated")
      i.automationEndpoint = "https://api.example.com/" ~ name;
    return i;
  }
}

/// The guided workflow through the driving ports.
unittest {
  auto c = newContainer();
  auto seeded = seedDemoData(c.ports, t, actor);
  assert(seeded.systems == 4 && seeded.scenarios == 3 && seeded.workflows == 2 && seeded.scenarioTasks == 12, seeded.to!string);
  assert(failsWith(IaErrorKind.conflict, () { seedDemoData(c.ports, t, actor); }));

  auto wf = c.ports.workflows.get(t, WorkflowId("wf-employee-wave1"));
  assert(wf.status == WorkflowStatus.inProgress && wf.totalTasks == 6 && wf.completedTasks == 1, wf.to!string);
  auto comm = taskNamed(c, wf.id, "Create communication arrangement SAP_COM_0001");
  auto perm = taskNamed(c, wf.id, "Grant OData API permissions in SuccessFactors");
  auto dest = taskNamed(c, wf.id, "Create the destinations in the BTP subaccount");
  auto golive = taskNamed(c, wf.id, "Approve go-live");
  assert(dest.dependsOn.length == 2 && comm.targetSystemId.value == "s4-cloud-prd" && perm.sourceSystemId.value == "sf-prd");

  // the automated task waits for both parallel tasks
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.tasks.start(t, golive.id, actor); }));
  foreach (task; [comm, perm]) {
    if (c.ports.tasks.get(t, task.id).status == TaskStatus.pending)
      c.ports.tasks.start(t, task.id, actor);
  }
  c.ports.tasks.complete(t, comm.id, "SAP_COM_0001 active", actor);
  auto noop = c.ports.tasks.runAutomation(t, UserId(automationActor));
  assert(noop.executed == 0 && noop.workflows == 1);
  c.ports.tasks.complete(t, perm.id, "", actor);

  // worker run: the automated task executes, the approval waits for a person
  auto run = c.ports.tasks.runAutomation(t, UserId(automationActor));
  assert(run.executed == 1 && run.succeeded == 1 && run.failed == 0, run.to!string);
  assert(c.ports.tasks.get(t, dest.id).status == TaskStatus.completed);
  assert(c.ports.tasks.get(t, dest.id).processedBy == automationActor);

  // reject → workflow failed → retry → approve → notification runs → completed
  c.ports.tasks.start(t, golive.id, actor);
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.tasks.skip(t, golive.id, "no", actor); }));
  c.ports.tasks.fail(t, golive.id, "Test replication incomplete", actor);
  assert(c.ports.workflows.get(t, wf.id).status == WorkflowStatus.failed);
  c.ports.tasks.retry(t, golive.id, actor);
  assert(c.ports.workflows.get(t, wf.id).status == WorkflowStatus.inProgress);
  c.ports.tasks.start(t, golive.id, actor);
  c.ports.tasks.complete(t, golive.id, "Approved", actor);
  assert(c.ports.tasks.get(t, golive.id).attempts == 2);
  run = c.ports.tasks.runAutomation(t, UserId(automationActor));
  assert(run.notified == 1, run.to!string);
  wf = c.ports.workflows.get(t, wf.id);
  assert(wf.status == WorkflowStatus.completed && wf.progressPercent == 100 && wf.completedAt > 0, wf.to!string);

  auto logs = c.ports.executions.listOf(t, wf.id).map!(l => l.action).array;
  assert(logs.canFind("workflow.created") && logs.canFind("automation.succeeded") && logs.canFind("task.rejected")
      && logs.canFind("notification.sent") && logs[$ - 1] == "workflow.completed", logs.to!string);

  // finished workflows can be deleted; the log stays
  c.ports.workflows.remove(t, wf.id, actor);
  assert(c.ports.tasks.listOf(t, wf.id).length == 0 && c.ports.executions.listOf(t, wf.id).length > 0);

  auto stats = c.ports.statistics.compute(t, "tester");
  assert(stats.systems == 4 && stats.activeScenarios == 2 && stats.draftScenarios == 1 && stats.openWorkflows == 1, stats.to!string);
}

/// Business rules of scenarios, templates, workflows and the landscape.
unittest {
  auto c = newContainer(["maxOpenWorkflows": Json(2), "workerIntervalSeconds": Json(0)]);
  assert(c.config.policy.runAutomationImmediately);

  SystemInput s4;
  s4.name = "S/4";
  s4.host = "s4.example.com";
  c.ports.systems.create(createCommand(t, actor, "s4", s4));
  SystemInput sf = s4;
  sf.name = "SF";
  sf.systemType = "sapSuccessFactors";
  sf.host = "sf.example.com";
  c.ports.systems.create(createCommand(t, actor, "sf", sf));
  assert(c.ports.systems.testConnection(t, SystemConnectionId("s4"), actor).status == ConnectionStatus.active);
  s4.host = "https://bad/path";
  assert(failsWith(IaErrorKind.invalid, () { c.ports.systems.create(createCommand(t, actor, "bad", s4)); }));

  DestinationInput d;
  d.name = "API";
  d.url = "https://api.example.com";
  d.systemId = "s4";
  c.ports.destinations.create(createCommand(t, actor, "api", d));
  d.name = "api"; // unique, case insensitive
  assert(failsWith(IaErrorKind.conflict, () { c.ports.destinations.create(createCommand(t, actor, "api2", d)); }));
  d.name = "OTHER";
  d.systemId = "nope";
  assert(failsWith(IaErrorKind.notFound, () { c.ports.destinations.create(createCommand(t, actor, "api3", d)); }));
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.systems.remove(t, SystemConnectionId("s4"), actor); }));

  ScenarioInput si;
  si.name = "SF → S/4";
  si.sourceSystemType = "sapSuccessFactors";
  si.targetSystemType = "sapS4HanaCloud";
  c.ports.scenarios.create(createCommand(t, actor, "sc", si));
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.scenarios.activate(t, ScenarioId("sc"), actor); })); // no templates
  auto first = templateInput("sc", 10, "Prepare");
  first.requiresTargetSystem = true;
  c.ports.scenarioTasks.create(createCommand(t, actor, "prep", first));
  auto auto_ = templateInput("sc", 20, "Call", "automated");
  auto_.destinationId = "api";
  auto_.automationEndpoint = "/run";
  c.ports.scenarioTasks.create(createCommand(t, actor, "call", auto_));
  auto chained = templateInput("sc", 30, "Chained", "automated");
  c.ports.scenarioTasks.create(createCommand(t, actor, "chain", chained));
  auto forward = templateInput("sc", 5, "Forward");
  forward.dependsOn = ["call"]; // lower sequence than its dependency
  assert(failsWith(IaErrorKind.invalid, () { c.ports.scenarioTasks.create(createCommand(t, actor, "fwd", forward)); }));
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.destinations.remove(t, DestinationId("api"), actor); }));

  CreateWorkflowCommand w;
  w.tenantId = t;
  w.actor = actor;
  w.scenarioId = "sc";
  w.sourceSystemId = "sf";
  w.targetSystemId = "s4";
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.workflows.create(w); })); // draft scenario
  c.ports.scenarios.activate(t, ScenarioId("sc"), actor);
  assert(failsWith(IaErrorKind.ruleViolation, () {
      c.ports.scenarioTasks.create(createCommand(t, actor, "late", templateInput("sc", 40, "Late")));
    })); // frozen
  UpdateCommand!ScenarioInput cat;
  cat.tenantId = t;
  cat.actor = actor;
  cat.id = "sc";
  cat.changes.values.category = "leadToCash";
  cat.changes.set("category");
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.scenarios.update(cat); }));

  // system types and required systems
  auto wrong = w;
  wrong.sourceSystemId = "s4";
  wrong.targetSystemId = "sf";
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.workflows.create(wrong); }));
  auto missing = w;
  missing.targetSystemId = "";
  assert(failsWith(IaErrorKind.invalid, () { c.ports.workflows.create(missing); }));

  // inline automation (worker off): completing the manual task runs the chain
  w.start = true;
  auto wf = c.ports.workflows.create(w);
  assert(wf.status == WorkflowStatus.inProgress && wf.totalTasks == 3);
  auto prep = taskNamed(c, wf.id, "Prepare");
  c.ports.tasks.start(t, prep.id, actor);
  c.ports.tasks.complete(t, prep.id, "ok", actor);
  wf = c.ports.workflows.get(t, wf.id);
  assert(wf.status == WorkflowStatus.completed, wf.to!string);
  assert(taskNamed(c, wf.id, "Call").result.canFind("https://api.example.com/run"));

  // the open workflow limit
  w.start = false;
  c.ports.workflows.create(w);
  c.ports.workflows.create(w);
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.workflows.create(w); }));
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.scenarios.remove(t, ScenarioId("sc"), actor); }));

  // copy → new draft version with remapped templates
  auto copy = c.ports.scenarios.copy(t, ScenarioId("sc"), "sc-v2", actor);
  assert(copy.isDraft && copy.version_ == "1.1" && copy.basedOnId.value == "sc");
  auto copied = c.ports.scenarioTasks.listOf(t, copy.id);
  assert(copied.length == 3 && copied.all!(x => !["prep", "call", "chain"].canFind(x.id.value)));
  c.ports.scenarios.deprecate(t, ScenarioId("sc"), actor);
  c.ports.scenarios.archive(t, ScenarioId("sc"), actor);
  assert(c.ports.scenarios.get(t, ScenarioId("sc")).status == ScenarioStatus.archived);
}

/// Failing automation, suspend/resume, terminate, assignment.
unittest {
  auto c = newContainer();
  seedDemoData(c.ports, t, actor);
  auto wf = c.ports.workflows.get(t, WorkflowId("wf-procurement"));
  assert(wf.status == WorkflowStatus.planned && wf.sourceSystemId.value == "s4-cloud-prd");
  auto realm = taskNamed(c, wf.id, "Configure the Ariba realm");
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.tasks.start(t, realm.id, actor); })); // not started
  c.ports.workflows.start(t, wf.id, actor);
  c.ports.workflows.suspend(t, wf.id, actor);
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.tasks.start(t, realm.id, actor); }));
  assert(c.ports.tasks.runAutomation(t, actor).workflows == 1); // only the other (running) workflow
  c.ports.workflows.resume(t, wf.id, actor);

  assert(failsWith(IaErrorKind.invalid, () { c.ports.tasks.assign(t, realm.id, "not valid!", "", actor); }));
  auto assigned = c.ports.tasks.assign(t, realm.id, "ada", "critical", actor);
  assert(assigned.assignedTo == "ada" && assigned.priority == TaskPriority.critical);
  assert(c.ports.statistics.compute(t, "ada").myOpenTasks == 1);

  c.ports.tasks.skip(t, realm.id, "Realm configured by SAP", actor);
  auto comm = taskNamed(c, wf.id, "Set up communication scenario SAP_COM_0A00");
  c.ports.tasks.start(t, comm.id, actor);
  c.ports.tasks.complete(t, comm.id, "", actor);

  // make the automated call fail (simulated) and check the workflow fails
  auto test = taskNamed(c, wf.id, "Send a test purchase order");
  auto stored = c.repositories.workflowTasks.findById(t, test.id);
  stored.automationPayload = `{"simulate":"failure"}`;
  c.repositories.workflowTasks.save(stored);
  auto run = c.ports.tasks.runAutomation(t, actor, wf.id);
  assert(run.failed == 1 && run.messages.length == 1, run.to!string);
  assert(c.ports.workflows.get(t, wf.id).status == WorkflowStatus.failed);
  assert(c.ports.statistics.compute(t, "").failuresLast24h >= 1);
  c.ports.tasks.skip(t, test.id, "Tested manually", actor);
  assert(c.ports.workflows.get(t, wf.id).status == WorkflowStatus.inProgress);

  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.workflows.remove(t, wf.id, actor); })); // open
  c.ports.workflows.terminate(t, wf.id, "Project stopped", actor);
  assert(c.ports.workflows.get(t, wf.id).terminationReason == "Project stopped");
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.workflows.resume(t, wf.id, actor); }));
  c.ports.workflows.remove(t, wf.id, actor);

  // housekeeping
  (cast(ManualClock) c.clock).advance(40 * 86_400);
  assert(c.ports.executions.purge(t, 30, actor) > 0);
}

/// REST and OData adapters (authMode open).
unittest {
  auto c = newContainer();
  auto router = routerOf(c);
  int status;

  auto health = call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200 && health["status"].get!string == "UP" && health["automation"].get!string == "simulate");
  call(router, "POST", "/api/v1/integration-automation/demo-data", Json.emptyObject, status);
  assert(status == 200);

  auto systems = call(router, "GET", "/api/v1/integration-automation/systems?$orderby=name", Json.undefined, status);
  assert(status == 200 && systems["count"].get!long == 4, systems.toString);
  auto tested = call(router, "POST", "/api/v1/integration-automation/systems/sf-prd/test", Json.emptyObject, status);
  assert(status == 200 && tested["status"].get!string == "active", tested.toString);

  auto tasks = call(router, "GET", "/api/v1/integration-automation/workflows/wf-employee-wave1/tasks", Json.undefined, status);
  assert(status == 200 && tasks["count"].get!long == 6, tasks.toString);
  auto rows = tasks["resources"].get!(Json[]);
  assert(rows[0]["status"].get!string == "completed" && rows[0]["sequenceNumber"].get!long == 10);
  auto waiting = rows.filter!(r => r["name"].get!string == "Approve go-live").front;
  assert(!waiting["ready"].get!bool && waiting["waitingFor"].get!string.canFind("destinations"), waiting.toString);

  // task operations over REST
  auto pending = rows.filter!(r => r["status"].get!string == "pending" && r["ready"].get!bool).array;
  assert(pending.length == 1, tasks.toString);
  auto id = pending[0]["id"].get!string;
  auto started = call(router, "POST", "/api/v1/integration-automation/tasks/" ~ id ~ "/start", Json.emptyObject, status);
  assert(status == 200 && started["status"].get!string == "inProgress", started.toString);
  call(router, "POST", "/api/v1/integration-automation/tasks/" ~ id ~ "/fail", Json.emptyObject, status);
  assert(status == 400); // errorMessage is required
  auto done = call(router, "POST", "/api/v1/integration-automation/tasks/" ~ id ~ "/complete", Json(["result": Json("ok")]), status);
  assert(status == 200 && done["status"].get!string == "completed");
  auto patched = call(router, "PATCH", "/api/v1/integration-automation/tasks/" ~ id, Json(["priority": Json("low")]), status);
  assert(status == 422, patched.toString); // done tasks cannot be reassigned
  auto running = rows.filter!(r => r["status"].get!string == "inProgress").front["id"].get!string;
  call(router, "POST", "/api/v1/integration-automation/tasks/" ~ running ~ "/complete", Json.emptyObject, status);
  assert(status == 200);

  // business rule errors map to 422, unknown resources to 404
  auto err = call(router, "POST", "/api/v1/integration-automation/scenarios/btp-event-mesh/archive", Json.emptyObject, status);
  assert(status == 200, err.toString); // a draft can be archived
  err = call(router, "POST", "/api/v1/integration-automation/workflows", Json(["scenarioId": Json("btp-event-mesh")]), status);
  assert(status == 422 && err["error"]["message"].get!string.canFind("archived"), err.toString);
  call(router, "GET", "/api/v1/integration-automation/workflows/nope/tasks", Json.undefined, status);
  assert(status == 404);
  call(router, "DELETE", "/api/v1/integration-automation/execution-logs/x", Json.undefined, status);
  assert(status == 405);

  auto run = call(router, "POST", "/api/v1/integration-automation/automation/run", Json.emptyObject, status);
  assert(status == 200 && run["executed"].get!long == 1, run.toString);
  auto stats = call(router, "GET", "/api/v1/integration-automation/statistics", Json.undefined, status);
  assert(status == 200 && stats["workflows"].get!long == 2 && stats["maxOpenWorkflows"].get!long == 15, stats.toString);
  auto meta = call(router, "GET", "/api/v1/integration-automation/meta", Json.undefined, status);
  assert(status == 200 && meta["taskTypes"].length == 4);

  // OData: $metadata, query options, create + action, PATCH
  auto metadata = call(router, "GET", "/odata/v4/integration-automation/$metadata", Json.undefined, status);
  assert(status == 200 && metadata.get!string.canFind(`EntitySet Name="WorkflowTasks"`), metadata.to!string[0 .. 200]);
  auto open = call(router, "GET", "/odata/v4/integration-automation/WorkflowTasks?$filter=ready%20eq%20true&$count=true",
    Json.undefined, status);
  assert(status == 200 && open["@odata.count"].get!long >= 1, open.toString);
  auto created = call(router, "POST", "/odata/v4/integration-automation/Workflows", Json(["scenarioId": Json("sf-s4-employee"),
      "sourceSystemId": Json("sf-prd"), "targetSystemId": Json("s4-cloud-prd"), "name": Json("Wave 2")]), status);
  assert(status == 201 && created["status"].get!string == "planned" && created["totalTasks"].get!long == 6, created.toString);
  auto wfId = created["id"].get!string;
  auto startedWf = call(router, "POST", "/odata/v4/integration-automation/StartWorkflow", Json(["id": Json(wfId)]), status);
  assert(status == 200 && startedWf["status"].get!string == "inProgress" && startedWf["currentTaskName"].get!string
      == "Review prerequisites", startedWf.toString);
  auto renamed = call(router, "PATCH", "/odata/v4/integration-automation/Workflows('" ~ wfId ~ "')",
    Json(["name": Json("Wave 2b"), "status": Json("completed")]), status); // status is computed → ignored
  assert(status == 200 || status == 204, renamed.toString);
  assert(c.ports.workflows.get(t, WorkflowId(wfId)).name == "Wave 2b" && c.ports.workflows.get(t, WorkflowId(wfId)).status
      == WorkflowStatus.inProgress);
  auto stat = call(router, "GET", "/odata/v4/integration-automation/Statistics", Json.undefined, status);
  assert(status == 200 && stat["openWorkflows"].get!long == 3, stat.toString);
}

/// Built-in login (authMode jwt): tokens and the scopes Read / Execute / Manage / Admin.
unittest {
  auto c = newContainer(["authMode": Json("jwt"), "jwtSecret": Json("0123456789abcdef0123456789abcdef"),
      "maxFailedLogins": Json(3)]);
  assert(c.security.mode == "jwt" && c.security.loginEnabled && !c.security.generatedSecret);
  assert(c.ports.users.ensureAdministrator(t, "admin", "admin password 1"));
  auto router = routerOf(c);
  int status;

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", "/api/v1/integration-automation/workflows", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/odata/v4/integration-automation/Workflows", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200); // probes stay public
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);

  auto login = call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("admin password 1")]), status);
  assert(status == 200 && login["scope"].get!string == "Read Execute Manage Admin", login.toString);
  auto admin = login["access_token"].get!string;
  call(router, "POST", "/api/v1/integration-automation/demo-data", Json.emptyObject, status, "application/json", "", admin);
  assert(status == 200);
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, "application/json", "", admin);
  assert(status == 200 && me["user"].get!string == "admin" && me["scopes"].length == 4);

  // an operator (Execute) and a viewer (Read)
  call(router, "POST", "/odata/v4/integration-automation/Users", Json(["id": Json("operator"),
      "password": Json("operator password"), "scopes": Json([Json("Execute")])]), status, "application/json", "", admin);
  assert(status == 201);
  call(router, "POST", "/odata/v4/integration-automation/Users", Json(["id": Json("viewer"),
      "password": Json("viewer password"), "scopes": Json([Json("Read")])]), status, "application/json", "", admin);
  assert(status == 201);
  auto op = call(router, "POST", "/auth/login", Json.undefined, status, "application/x-www-form-urlencoded",
    "username=operator&password=operator%20password", "");
  assert(status == 200 && op["scope"].get!string == "Read Execute", op.toString);
  auto operator = op["access_token"].get!string;
  auto viewer = call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("viewer password")]),
    status)["access_token"].get!string;

  // Read
  call(router, "GET", "/odata/v4/integration-automation/WorkflowTasks", Json.undefined, status, "application/json", "", viewer);
  assert(status == 200);
  call(router, "POST", "/odata/v4/integration-automation/StartWorkflow", Json(["id": Json("wf-procurement")]), status,
    "application/json", "", viewer);
  assert(status == 403);
  // Execute: run workflows and tasks, but not maintain the landscape or users
  auto started = call(router, "POST", "/odata/v4/integration-automation/StartWorkflow", Json(["id": Json("wf-procurement")]),
    status, "application/json", "", operator);
  assert(status == 200 && started["status"].get!string == "inProgress", started.toString);
  auto assigned = call(router, "PATCH", "/odata/v4/integration-automation/WorkflowTasks('" ~ started["currentTaskId"].get!string
      ~ "')", Json(["assignedTo": Json("operator")]), status, "application/json", "", operator);
  assert(status == 200 || status == 204, assigned.toString);
  auto mine = call(router, "GET", "/api/v1/integration-automation/my-tasks", Json.undefined, status, "application/json", "", operator);
  assert(status == 200 && mine["count"].get!long == 1, mine.toString);
  call(router, "POST", "/api/v1/integration-automation/systems/sf-prd/test", Json.emptyObject, status, "application/json", "", operator);
  assert(status == 403);
  call(router, "DELETE", "/api/v1/integration-automation/destinations/btp-automation", Json.undefined, status,
    "application/json", "", operator);
  assert(status == 403);
  call(router, "GET", "/odata/v4/integration-automation/Users", Json.undefined, status, "application/json", "", operator);
  assert(status == 403);

  // password change, lockout, the last administrator
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("viewer password"), "newPassword": Json("a better password")]),
    status, "application/json", "", viewer);
  assert(status == 204);
  foreach (_; 0 .. 3)
    call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("nope")]), status);
  auto locked = call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("a better password")]), status);
  assert(status == 401 && locked["error"]["message"].get!string.canFind("locked"), locked.toString);
  assert(failsWith(IaErrorKind.ruleViolation, () { c.ports.users.deleteUser(t, UserAccountId("admin"), UserId("operator")); }));
  call(router, "GET", "/api/v1/integration-automation/workflows", Json.undefined, status, "application/json", "",
    admin[0 .. $ - 2] ~ "xx");
  assert(status == 401); // tampered token
}

/// The command line adapter.
unittest {
  auto c = newContainer();
  string out_;
  auto cli = buildIaCli(c, (string s) @safe { out_ ~= s; });
  assert(cli.run(["seed", "--json"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // not empty → conflict
  assert(cli.run(["stats"]) == 0 && cli.run(["list", "Workflows"]) == 0 && cli.run(["sets"]) == 0);
  out_ = "";
  assert(cli.run(["tasks", "wf-employee-wave1", "--json"]) == 0, out_);
  assert(parseJsonString(out_).length == 6, out_);
  assert(cli.run(["test", "btp-eu10"]) == 0 && cli.run(["test", "nope"]) == 1);
  assert(cli.run(["instantiate", "sf-s4-employee", "--source=sf-prd", "--target=s4-cloud-prd", "--start"]) == 0, out_);
  assert(cli.run(["instantiate", "btp-event-mesh"]) == 1); // draft
  assert(cli.run(["copy", "sf-s4-employee", "sf-s4-v2"]) == 0 && cli.run(["activate", "sf-s4-v2"]) == 0);
  assert(cli.run(["suspend", "wf-employee-wave1"]) == 0 && cli.run(["resume", "wf-employee-wave1"]) == 0);
  assert(cli.run(["run"]) == 0 && cli.run(["purge", "30"]) == 0 && cli.run(["config"]) == 0);
  assert(cli.run(["terminate", "wf-procurement", "not needed"]) == 0);
  assert(cli.run(["token", "admin"]) == 1); // authMode open: no issuer
}

/// Batching file store: instantiating a workflow writes the snapshot once,
/// a second container (the CLI next to the server) sees the data.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;
  import std.uuid : randomUUID;

  auto file = buildPath(tempDir, "uim-ia-" ~ randomUUID.toString, "data.json");
  scope (exit)
    if (exists(dirName(file)))
      rmdirRecurse(dirName(file));
  auto storage = createStorage("file", file);
  auto c = newContainer(null, storage);
  seedDemoData(c.ports, t, actor);
  auto store = cast(BatchingFileDocumentStore) storage.store;
  auto before = store.flushes;
  CreateWorkflowCommand w;
  w.tenantId = t;
  w.actor = actor;
  w.scenarioId = "sf-s4-employee";
  w.sourceSystemId = "sf-prd";
  w.targetSystemId = "s4-cloud-prd";
  c.ports.workflows.create(w);
  assert(store.flushes == before + 1, (store.flushes - before).to!string); // workflow + 6 tasks + log entry

  Json[string] o;
  o["storage"] = "file";
  o["dataFile"] = file;
  auto other = new IaContainer(loadIaConfig(o, "/nonexistent"));
  other.events.log = false;
  assert(other.ports.workflows.list(t).length == 3);
}
