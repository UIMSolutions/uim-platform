/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests: the OData v4 HTTP controller and the REST controller
/// on top of a fully wired container (memory store, static provider gateway).
module task_center_tests;

import uim.platform.task_center;

@safe:

version (unittest) {
  TaskCenterContainer testContainer(StaticTaskProviderGateway gateway = null, RecordingTaskEventPublisher events = null) {
    Json[string] o;
    o["storage"] = "memory";
    return new TaskCenterContainer(loadTaskCenterConfig(o, "/nonexistent"), gateway !is null ? gateway : new StaticTaskProviderGateway,
      null, events !is null ? events : new RecordingTaskEventPublisher);
  }

  Json params(string[string] values) {
    auto j = Json.emptyObject;
    foreach (k, v; values)
      j[k] = v;
    return j;
  }

  ODataHttpRequest req(string method, string path, string body = "", string[string] query = null) {
    ODataHttpRequest r;
    r.method = method;
    r.path = path;
    r.body = body;
    r.query = query;
    if (body.length)
      r.headers["content-type"] = "application/json";
    return r;
  }

  int statusOf(scope void delegate() @safe dg) {
    try
      dg();
    catch (EntitySetException e)
      return e.status;
    return 0;
  }
}

/// Full lifecycle through the engine (what OData, REST, CLI and GUI call).
@safe unittest {
  auto events = new RecordingTaskEventPublisher;
  auto c = testContainer(null, events);
  auto e = c.engine;
  auto admin = RequestContext.local("acme", "test", "admin");
  auto anna = RequestContext.local("acme", "test", "anna");
  auto ben = RequestContext.local("acme", "test", "ben");

  auto def = e.create(admin, "TaskDefinitions", parseJsonString(`{"name": "Travel Request",
    "category": "approval", "defaultPriority": "high", "dueInDays": 2, "requiresClaim": true,
    "allowedActions": ["approve", "reject", "cancel"]}`));
  assert(def["openTaskCount"].get!long == 0);

  auto taskPayload = parseJsonString(`{"title": "Trip to Walldorf", "assignee": "anna", "customAttributes": "{\"costCenter\": \"4711\"}"}`);
  taskPayload["definitionId"] = def["id"];
  auto task = e.create(admin, "Tasks", taskPayload);
  auto t1 = task["id"].get!string;
  assert(task["priority"].get!string == "high" && task["status"].get!string == "open");
  assert(task["dueDate"].get!string == addDays(todayIso(), 2));
  assert(task["allowedActions"].length == 3);

  // status is server managed: PATCH ignores it
  e.update(admin, "Tasks", t1, parseJsonString(`{"status": "completed", "description": "2 nights"}`));
  assert(e.read(anna, "Tasks", t1)["status"].get!string == "open");

  // availableActions depend on the caller
  auto forAnna = e.read(anna, "Tasks", t1)["availableActions"];
  assert(forAnna.toString.canFind("claim") && !forAnna.toString.canFind("approve")); // requires claim first

  auto claimed = e.invoke(anna, "PerformTaskAction", params(["taskId": t1, "action": "claim"]));
  assert(claimed["isClaimed"].get!bool && claimed["claimedBy"].get!string == "anna");
  assert(statusOf(() { e.invoke(ben, "PerformTaskAction", params(["taskId": t1, "action": "claim"])); }) == 409);
  assert(statusOf(() { e.invoke(ben, "PerformTaskAction", params(["taskId": t1, "action": "release"])); }) == 403);
  assert(statusOf(() { e.invoke(anna, "PerformTaskAction", params(["taskId": t1, "action": "complete"])); }) == 422);
  assert(statusOf(() { e.invoke(anna, "PerformTaskAction", params(["taskId": t1, "action": "teleport"])); }) == 400);

  auto rejected = e.invoke(anna, "PerformTaskAction", params(["taskId": t1, "action": "reject", "comment": "Use video call"]));
  assert(rejected["status"].get!string == "completed" && rejected["outcome"].get!string == "rejected");
  assert(rejected["commentCount"].get!long == 1);

  string[string] byTask = ["$filter": "taskId eq '" ~ t1 ~ "'"];
  assert(e.query(admin, "TaskActions", byTask).total == 2);
  assert(statusOf(() { e.remove(admin, "TaskActions", e.query(admin, "TaskActions", byTask).rows[0]["id"].get!string); }) == 405);
  assert(statusOf(() { e.update(admin, "Tasks", t1, parseJsonString(`{"title": "x"}`)); }) == 422); // finished

  auto stats = e.read(admin, "Statistics", "");
  assert(stats["tasks"].get!long == 1 && stats["rejectedTasks"].get!long == 1 && stats["actions"].get!long == 2);

  // tenant isolation
  assert(e.query(RequestContext.local("other", "test", "x"), "Tasks", (string[string]).init).total == 0);

  // deleting a task removes its comments and history
  e.remove(admin, "Tasks", t1);
  assert(e.query(admin, "TaskActions", byTask).total == 0 && e.query(admin, "TaskComments", byTask).total == 0);
  assert(events.types.canFind("sap.taskcenter.task.rejected") && events.types.canFind("sap.taskcenter.task.deleted"));
}

/// Personal data: substitution rules and filters belong to their owner.
@safe unittest {
  auto c = testContainer();
  auto e = c.engine;
  RequestContext anna = RequestContext.local("acme", "http", "anna");
  anna.authenticated = true; // a real (token) user without Manage
  anna.scopes = ["Read", "Process"];
  RequestContext ben = anna;
  ben.userId = "ben";

  auto rule = e.create(anna, "SubstitutionRules", parseJsonString(`{"substituteId": "ben", "isAutoForward": true}`));
  assert(rule["userId"].get!string == "anna" && rule["effectiveStatus"].get!string == "active");
  assert(statusOf(() { e.create(anna, "SubstitutionRules", parseJsonString(`{"userId": "carl", "substituteId": "dora"}`)); }) == 403);
  assert(statusOf(() { e.create(ben, "SubstitutionRules", parseJsonString(`{"substituteId": "anna", "isAutoForward": true}`)); }) == 422); // cycle
  assert(statusOf(() { e.remove(ben, "SubstitutionRules", rule["id"].get!string); }) == 403);
  assert(statusOf(() { e.create(anna, "SubstitutionRules", parseJsonString(`{"substituteId": "ben", "startDate": "2026-05-02", "endDate": "2026-05-01"}`)); }) == 400);

  auto first = e.create(anna, "UserTaskFilters", parseJsonString(`{"name": "Mine", "criteria": "assignee=$me", "isDefault": true}`));
  auto second = e.create(anna, "UserTaskFilters", parseJsonString(`{"name": "Urgent", "criteria": "priority=veryHigh, status=open", "isDefault": true}`));
  assert(first["odataFilter"].get!string == "assignee eq 'anna'");
  assert(second["odataFilter"].get!string == "priority eq 'veryHigh' and status eq 'open'");
  assert(!e.read(anna, "UserTaskFilters", first["id"].get!string)["isDefault"].get!bool); // only one default
  assert(statusOf(() { e.create(anna, "UserTaskFilters", parseJsonString(`{"name": "Mine"}`)); }) == 409);
  assert(statusOf(() { e.create(anna, "UserTaskFilters", parseJsonString(`{"name": "Bad", "criteria": "mood=happy"}`)); }) == 400);

  // a new task for anna goes to ben (auto-forward)
  auto admin = RequestContext.local("acme", "test", "admin");
  auto t = e.create(admin, "Tasks", parseJsonString(`{"title": "Approve budget", "assignee": "anna"}`));
  assert(t["assignee"].get!string == "ben" && t["substitutedFor"].get!string == "anna");
}

/// The OData v4 HTTP surface: $metadata, queries, actions, IEEE754 and errors.
@safe unittest {
  auto c = testContainer();
  auto odata = new ODataController(c.engine, "/odata/v4/task-center", "default");

  auto meta = odata.dispatch(RequestContext.local("default", "odata"), req("GET", "$metadata"));
  assert(meta.status == 200 && meta.body.canFind(`EntitySet Name="Tasks"`) && meta.body.canFind(`ActionImport Name="PerformTaskAction"`));

  auto ctx = RequestContext.local("default", "odata", "anna");
  auto created = odata.dispatch(ctx, req("POST", "Tasks", `{"title": "Review contract", "category": "review", "assignee": "anna"}`));
  assert(created.status == 201, created.body);
  auto id = parseJsonString(created.body)["id"].get!string;

  auto list = odata.dispatch(ctx, req("GET", "Tasks", "", ["$filter": "assignee eq 'anna'", "$count": "true",
      "$select": "title,status"]));
  assert(list.status == 200 && parseJsonString(list.body)["@odata.count"].get!long == 1, list.body);

  auto approve = odata.dispatch(ctx, req("POST", "PerformTaskAction", `{"taskId": "` ~ id ~ `", "action": "approve"}`));
  assert(approve.status == 200 && parseJsonString(approve.body)["outcome"].get!string == "approved", approve.body);

  auto unknown = odata.dispatch(ctx, req("GET", "Tasks('nope')"));
  assert(unknown.status == 404);
  auto invalid = odata.dispatch(ctx, req("POST", "Tasks", `{"title": "x", "dueDate": "someday"}`));
  assert(invalid.status == 400, invalid.body);
  auto stats = odata.dispatch(ctx, req("GET", "Statistics"));
  assert(stats.status == 200 && parseJsonString(stats.body)["approvedTasks"].get!long == 1);
}

/// Scopes are enforced when authentication is required.
@safe unittest {
  auto c = testContainer();
  c.engine.enforceScopes = true;
  RequestContext viewer;
  viewer.tenantId = "default";
  viewer.userId = "vera";
  viewer.authenticated = true;
  viewer.scopes = ["uim-task-center!t1.Read"];
  assert(c.engine.query(viewer, "Tasks", (string[string]).init).total == 0);
  assert(statusOf(() { c.engine.create(viewer, "Tasks", parseJsonString(`{"title": "x"}`)); }) == 403);
  assert(statusOf(() { c.engine.invoke(viewer, "SyncAllProviders", Json.emptyObject); }) == 403);
}
