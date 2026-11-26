/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the scaling flow through
/// the ports (seed → metrics → evaluation → schedule / rule / cool-down →
/// history), the business rules of bindings, policies, rules, schedules and
/// custom metrics, the REST API and the OData endpoint over vibe.d test
/// requests, the built-in JWT login with scopes, the CLI and the batching
/// file store.
module tests.autoscaler_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.application_autoscaler;

@safe:

version (unittest) {
  /// 2026-11-25T10:00:00Z — a Wednesday inside the demo's business hours.
  long t0() {
    return parseIsoTime("2026-11-25T10:00:00Z");
  }

  struct TestBed {
    AasContainer c;
    ManualClock clock;
    SimulatedInstanceController platform;
  }

  TestBed newBed(Json[string] extra = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["evaluationIntervalSeconds"] = 0;
    o["passwordIterations"] = 1000;
    foreach (k, v; extra)
      o[k] = v;
    TestBed b;
    b.clock = new ManualClock(t0);
    b.platform = new SimulatedInstanceController;
    b.c = new AasContainer(loadAasConfig(o, "/nonexistent"), storage, b.clock, b.platform);
    b.c.events.log = false;
    return b;
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

  URLRouter routerOf(AasContainer c) {
    c.engine.enforceScopes = c.security.requireAuthentication; // as in app.d
    auto router = new URLRouter;
    new AasHealthController(c.config, c.security.mode, c.instances.mode, c.metrics).registerRoutes(router, c.config.apiPath);
    new AuthController(c.ports, c.security).registerRoutes(router);
    new AasApiController(c.engine, c.ports, c.security, "/api/v1", "2.0.0", 1024 * 1024,
      capabilitiesJson(c.instances.mode, c.config.policy)).registerRoutes(router);
    auto odata = new ODataController(c.engine, "/odata/v4/autoscaler");
    odata.verifier = c.security.verifier;
    odata.requireAuthentication = c.security.requireAuthentication;
    odata.registerRoutes(router);
    return router;
  }

  auto t = TenantId("default");
  auto actor = UserId("tester");

  AppBinding binding(AasContainer c, string id) {
    return c.ports.bindings.get(t, AppBindingId(id));
  }

  ScalingPolicy newPolicy(AasContainer c, string id, int min, int max, string allow = "sameApp") {
    PolicyInput i;
    i.name = id;
    i.instanceMinCount = min;
    i.instanceMaxCount = max;
    i.customMetricAllowFrom = allow;
    return c.ports.policies.create(createCommand(t, actor, id, i));
  }

  AppBinding newBinding(AasContainer c, string id, string policy, int instances, string serviceInstance = "si-1") {
    BindingInput i;
    i.name = id;
    i.appGuid = "guid-" ~ id;
    i.policyId = policy;
    i.currentInstances = instances;
    i.serviceInstanceId = serviceInstance;
    return c.ports.bindings.create(createCommand(t, actor, id, i));
  }
}

/// The demo tenant: schedule start, cool-down, dynamic scale-out, custom
/// metric percentages, skipped bindings and the history.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto seeded = seedDemoData(c.ports, t, actor);
  assert(seeded.policies == 3 && seeded.bindings == 5 && seeded.rules == 6 && seeded.schedules == 2 && seeded.samples > 50);
  assert(failsWith(AasErrorKind.ruleViolation, () { seedDemoData(c.ports, t, actor); }));

  // 10:00 on a Wednesday: business hours (3..10, initial 4) apply to the web apps
  auto run = c.ports.scaling.evaluateAll(t, actor);
  assert(run.bindings == 5 && run.evaluated == 3 && run.skipped == 2 && run.scaledOut == 3, run.messages.to!string);
  assert(binding(c, "shop-frontend").currentInstances == 4);
  assert(binding(c, "order-service").currentInstances == 4);
  assert(binding(c, "invoice-worker").currentInstances == 3); // jobqueue 240 > 100 → +50% of 2
  assert(binding(c, "reporting-ui").currentInstances == 1 && binding(c, "legacy-admin").currentInstances == 1);
  auto events = c.ports.scaling.listEvents(t);
  assert(events.length == 3 && events.all!(e => e.status == ScalingStatus.succeeded));
  assert(events.canFind!(e => e.trigger == ScalingTrigger.schedule && e.scheduleId.value.length));
  assert(events.canFind!(e => e.trigger == ScalingTrigger.dynamic && e.metricName == "jobqueue" && e.metricValue == 240));
  assert(b.platform.calls == 3);

  // right after scaling: the CPU rule of order-service cools down
  auto r = c.ports.scaling.evaluate(t, AppBindingId("order-service"), actor);
  assert(r.status == ScalingStatus.ignored && r.reason.canFind("cooling down"), r.reason);
  // after the cool-down the hot CPU (91 % for 5 min) adds two instances
  b.clock.advance(301);
  r = c.ports.scaling.evaluate(t, AppBindingId("order-service"), actor);
  assert(r.status == ScalingStatus.succeeded && r.direction == ScalingDirection.scaleOut && r.newInstances == 6, r.reason);
  assert(r.trigger == ScalingTrigger.dynamic && r.maxInstances == 10 && r.limitSource == "Business hours", r.limitSource);
  auto preview = c.ports.scaling.preview(t, AppBindingId("shop-frontend"));
  assert(!preview.changes, preview.reason); // CPU 45 %: nothing to do
  // metrics go stale: no rule fires any more
  b.clock.advance(3600);
  r = c.ports.scaling.evaluate(t, AppBindingId("order-service"), actor);
  assert(r.status == ScalingStatus.ignored && r.reason.canFind("older"), r.reason);

  // statistics
  auto s = c.ports.statistics.compute(t);
  assert(s.bindings == 5 && s.autoscaledBindings == 4 && s.policies == 3 && s.activePolicies == 2 && s.rules == 6);
  assert(s.scaleOutsLast24h == 4 && s.instances == 4 + 6 + 3 + 1 + 1 && s.activeSchedules == 1, s.to!string);

  // suspend: skipped, manual scaling still works and starts a cool-down
  c.ports.bindings.suspend(t, AppBindingId("order-service"), actor);
  assert(c.ports.scaling.evaluate(t, AppBindingId("order-service"), actor).reason == "autoscaling is suspended");
  r = c.ports.scaling.scaleManually(t, AppBindingId("order-service"), 2, "maintenance", actor);
  assert(r.trigger == ScalingTrigger.manual && r.newInstances == 2 && binding(c, "order-service").lastScaledAt == b.clock.now);
  assert(failsWith(AasErrorKind.invalid, () { c.ports.scaling.scaleManually(t, AppBindingId("order-service"), 11, "", actor); }));
  assert(failsWith(AasErrorKind.ruleViolation, () { c.ports.scaling.scaleManually(t, AppBindingId("order-service"), 2, "", actor); }));
  c.ports.bindings.resume(t, AppBindingId("order-service"), actor);
  // back inside the schedule limits (3..10) at the next evaluation
  r = c.ports.scaling.evaluate(t, AppBindingId("order-service"), actor);
  assert(r.trigger == ScalingTrigger.schedule && r.newInstances == 3, r.reason);
  // after business hours the policy limits (2..10) apply again
  b.clock.current = parseIsoTime("2026-11-25T20:00:00Z");
  assert(c.ports.scaling.preview(t, AppBindingId("order-service")).limits.source == "policy");

  // deleting a binding removes its samples and history
  auto before = c.ports.metrics.list(t).length;
  auto own = c.ports.metrics.listOf(t, AppBindingId("order-service")).length;
  c.ports.bindings.remove(t, AppBindingId("order-service"), actor);
  assert(c.ports.metrics.list(t).length == before - own);
  assert(!c.ports.scaling.listEvents(t).canFind!(e => e.bindingId.value == "order-service"));
}

/// Business rules of policies, rules, schedules, bindings and metrics.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto p = newPolicy(c, "web", 1, 4);
  newPolicy(c, "web-x", 1, 2); // a different name is fine
  PolicyInput dup;
  dup.name = "WEB";
  assert(failsWith(AasErrorKind.conflict, () { c.ports.policies.create(createCommand(t, actor, "", dup)); }));
  assert(failsWith(AasErrorKind.invalid, () { newPolicy(c, "bad", 5, 2); }));

  RuleInput ri;
  ri.policyId = "web";
  ri.metricType = "cpu";
  ri.operator = "gt";
  ri.threshold = 70;
  ri.adjustment = " +2 ";
  auto rule = c.ports.rules.create(createCommand(t, actor, "cpu-up", ri));
  assert(rule.operator == ComparisonOperator.gt && rule.adjustment == "+2");
  ri.adjustment = "2";
  assert(failsWith(AasErrorKind.invalid, () { c.ports.rules.create(createCommand(t, actor, "", ri)); }));
  ri.adjustment = "+1";
  ri.policyId = "nope";
  assert(failsWith(AasErrorKind.notFound, () { c.ports.rules.create(createCommand(t, actor, "", ri)); }));
  RuleInput move;
  move.policyId = "other";
  assert(failsWith(AasErrorKind.invalid, () {
    c.ports.rules.update(updateCommand(t, actor, "cpu-up", move, "policyId"));
  }));

  // schedules: days by name, overlapping specific dates refused
  ScheduleInput si;
  si.policyId = "web";
  si.startTime = "08:00";
  si.endTime = "18:00";
  si.daysOfWeek = ["mon", "Tue", "5"];
  si.instanceMinCount = 2;
  si.instanceMaxCount = 6;
  auto weekly = c.ports.schedules.create(createCommand(t, actor, "weekly", si));
  assert(weekly.daysOfWeek == ["1", "2", "5"] && !c.ports.schedules.isActive(t, weekly)); // Wednesday
  ScheduleInput once;
  once.policyId = "web";
  once.kind = "specificDate";
  once.startDateTime = "2026-12-01T00:00";
  once.endDateTime = "2026-12-03T00:00";
  once.startTime = "ignored";
  c.ports.schedules.create(createCommand(t, actor, "sale", once));
  once.startDateTime = "2026-12-02T12:00";
  once.endDateTime = "2026-12-04T00:00";
  assert(failsWith(AasErrorKind.ruleViolation, () { c.ports.schedules.create(createCommand(t, actor, "", once)); }));
  once.startDateTime = "2026-12-03T00:00";
  c.ports.schedules.create(createCommand(t, actor, "sale2", once)); // touching is fine

  // bindings: unique GUID, immutable instances, reference checks
  newBinding(c, "app1", "web", 2);
  BindingInput again;
  again.name = "copy";
  again.appGuid = "guid-app1";
  assert(failsWith(AasErrorKind.conflict, () { c.ports.bindings.create(createCommand(t, actor, "", again)); }));
  BindingInput patch;
  patch.currentInstances = 9;
  assert(failsWith(AasErrorKind.invalid, () {
    c.ports.bindings.update(updateCommand(t, actor, "app1", patch, "currentInstances"));
  }));
  patch.policyId = "ghost";
  assert(failsWith(AasErrorKind.notFound, () { c.ports.bindings.update(updateCommand(t, actor, "app1", patch, "policyId")); }));
  assert(failsWith(AasErrorKind.ruleViolation, () { c.ports.policies.remove(t, ScalingPolicyId("web"), actor); }));

  // copy: rules and schedules travel along, the copy is inactive
  auto copy = c.ports.policies.copy(t, ScalingPolicyId("web"), "web-v2", actor);
  assert(copy.status == PolicyStatus.inactive && copy.name == "web (copy)");
  assert(c.ports.rules.listOf(t, copy.id).length == 1 && c.ports.schedules.listOf(t, copy.id).length == 3);
  assert(c.ports.policies.copy(t, ScalingPolicyId("web"), "", actor).name == "web (copy) 2");
  c.ports.policies.remove(t, ScalingPolicyId("web-v2"), actor);
  assert(c.ports.rules.list(t).length == 2 && c.ports.schedules.list(t).length == 6);
  assert(failsWith(AasErrorKind.notFound, () { c.ports.policies.get(t, copy.id); }));

  // custom metrics: by GUID, sender rules
  SubmitMetricRequest m;
  m.tenantId = t;
  m.actor = actor;
  m.appGuid = "guid-app1";
  m.metricName = "CPU";
  m.value = 55;
  auto sample = c.ports.metrics.submit(m);
  assert(sample.metricName == "cpu" && sample.unit == "%" && sample.measuredAt == b.clock.now);
  m.metricName = "jobqueue";
  m.senderAppGuid = "guid-app2";
  assert(failsWith(AasErrorKind.ruleViolation, () { c.ports.metrics.submit(m); })); // sameApp
  auto open = newPolicy(c, "open", 1, 3, "boundApp");
  c.ports.bindings.attachPolicy(t, AppBindingId("app1"), open.id, actor);
  assert(failsWith(AasErrorKind.ruleViolation, () { c.ports.metrics.submit(m); })); // sender not bound
  newBinding(c, "app2", "", 1, "si-1");
  assert(c.ports.metrics.submit(m).isCustom);
  m.measuredAt = "2027-01-01T00:00:00Z";
  assert(failsWith(AasErrorKind.invalid, () { c.ports.metrics.submit(m); }));
  m.measuredAt = "";
  m.metricName = "custom";
  assert(failsWith(AasErrorKind.invalid, () { c.ports.metrics.submit(m); }));

  // a failing platform call is recorded, the instances stay
  RuleInput q;
  q.policyId = "open";
  q.metricType = "custom";
  q.customMetricName = "jobqueue";
  q.threshold = 10;
  q.breachDurationSeconds = 60;
  c.ports.rules.create(createCommand(t, actor, "", q));
  SimulateLoadRequest load;
  load.tenantId = t;
  load.actor = actor;
  load.bindingId = "app1";
  load.metricName = "jobqueue";
  load.value = 50;
  load.durationSeconds = 120;
  assert(c.ports.metrics.simulate(load).length == 5);
  b.platform.failNext = "quota exceeded";
  auto r = c.ports.scaling.evaluate(t, AppBindingId("app1"), actor);
  assert(r.status == ScalingStatus.failed && r.message == "quota exceeded" && binding(c, "app1").currentInstances == 2);
  assert(c.ports.scaling.getEvent(t, r.eventId).newInstances == 3 && binding(c, "app1").lastDecision.startsWith("failed"));
  r = c.ports.scaling.evaluate(t, AppBindingId("app1"), actor);
  assert(r.status == ScalingStatus.succeeded && r.newInstances == 3);
  c.ports.bindings.detachPolicy(t, AppBindingId("app1"), actor);
  assert(c.ports.scaling.evaluate(t, AppBindingId("app1"), actor).reason == "no policy attached");

  // retention
  b.clock.advance(49 * 3600);
  auto purged = c.ports.metrics.purge(t, actor);
  assert(purged.samples > 0 && c.ports.metrics.list(t).length == 0);
  b.clock.advance(31 * 86_400);
  assert(c.ports.metrics.purge(t, actor).events == 2 && c.ports.scaling.listEvents(t).length == 0);
}

/// REST API and OData endpoint.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto router = routerOf(c);
  int status;
  enum api = "/api/v1/autoscaler";
  enum od = "/odata/v4/autoscaler";

  auto seeded = call(router, "POST", api ~ "/demo-data", Json.emptyObject, status);
  assert(status == 200 && seeded["bindings"].get!long == 5, seeded.toString);
  auto list = call(router, "GET", api ~ "/bindings?$filter=autoscaled eq true&$orderby=name", Json.undefined, status);
  assert(status == 200 && list["count"].get!long == 3, list.toString);
  assert(list["resources"][0]["name"].get!string == "invoice-worker");
  auto one = call(router, "GET", api ~ "/bindings/shop-frontend", Json.undefined, status);
  assert(status == 200 && one["policyName"].get!string == "Web standard" && one["limitSource"].get!string == "Business hours"
      && one["minInstances"].get!long == 3 && one["sampleCount"].get!long == 42, one.toString);

  auto ev = call(router, "POST", api ~ "/bindings/order-service/evaluate", Json.emptyObject, status);
  assert(status == 200 && ev["status"].get!string == "succeeded" && ev["newInstances"].get!long == 4, ev.toString);
  auto hist = call(router, "GET", api ~ "/bindings/order-service/history", Json.undefined, status);
  assert(status == 200 && hist["count"].get!long == 1 && hist["resources"][0]["trigger"].get!string == "schedule", hist.toString);
  auto pre = call(router, "GET", api ~ "/bindings/order-service/preview", Json.undefined, status);
  assert(status == 200 && pre["status"].get!string == "preview", pre.toString);
  call(router, "GET", api ~ "/bindings/nope/history", Json.undefined, status);
  assert(status == 404);

  // a policy with a rule over REST, attached to legacy-admin
  auto pol = call(router, "POST", api ~ "/policies", Json(["id": Json("tiny"), "name": Json("Tiny"),
      "instanceMinCount": Json(1), "instanceMaxCount": Json(3)]), status);
  assert(status == 201 && pol["status"].get!string == "active", pol.toString);
  auto rule = call(router, "POST", api ~ "/rules", Json(["policyId": Json("tiny"), "metricType": Json("throughput"),
      "operator": Json(">"), "threshold": Json(100), "breachDurationSeconds": Json(60), "adjustment": Json("+1")]), status);
  assert(status == 201 && rule["summary"].get!string == "throughput > 100 for 60s → +1", rule.toString);
  call(router, "POST", api ~ "/rules", Json(["policyId": Json("tiny"), "threshold": Json(500)]), status);
  assert(status == 400); // cpu threshold is a percentage
  auto att = call(router, "POST", api ~ "/bindings/legacy-admin/policy", Json(["policyId": Json("tiny")]), status);
  assert(status == 200 && att["policyName"].get!string == "Tiny" && att["autoscaled"].get!bool, att.toString);
  call(router, "PATCH", api ~ "/policies/tiny", Json(["instanceMaxCount": Json(0)]), status);
  assert(status == 400);
  call(router, "DELETE", api ~ "/policies/tiny", Json.undefined, status);
  assert(status == 422); // used by legacy-admin
  call(router, "PATCH", api ~ "/bindings/legacy-admin", Json(["appGuid": Json("other")]), status);
  assert(status == 200); // immutable: silently ignored by the engine on update

  // metrics: by binding and by application GUID (batch)
  auto ms = call(router, "POST", api ~ "/bindings/legacy-admin/metrics", Json(["metricName": Json("throughput"),
      "value": Json(150)]), status);
  assert(status == 201 && ms["unit"].get!string == "rps", ms.toString);
  auto batch = call(router, "POST", api ~ "/apps/19ce62f8-legacy-admin/metrics", parseJsonString(
      `{"metrics":[{"name":"throughput","value":160},{"metricName":"throughput","value":170}]}`), status);
  assert(status == 201 && batch["count"].get!long == 2, batch.toString);
  call(router, "POST", api ~ "/apps/unknown/metrics", Json(["metricName": Json("cpu"), "value": Json(1)]), status);
  assert(status == 404);
  auto sim = call(router, "POST", api ~ "/bindings/legacy-admin/simulate", Json(["metricName": Json("throughput"),
      "value": Json(300), "durationSeconds": Json(120)]), status);
  assert(status == 200 && sim["samples"].get!long == 5, sim.toString);
  auto all = call(router, "POST", api ~ "/scaling/evaluate", Json.emptyObject, status);
  assert(status == 200 && all["scaledOut"].get!long >= 2, all.toString);
  assert(binding(c, "legacy-admin").currentInstances == 2);
  auto scaled = call(router, "POST", api ~ "/bindings/legacy-admin/scale", Json(["instances": Json(3), "reason": Json("test")]),
    status);
  assert(status == 200 && scaled["trigger"].get!string == "manual", scaled.toString);
  call(router, "POST", api ~ "/bindings/legacy-admin/scale", Json(["instances": Json(30)]), status);
  assert(status == 400);
  call(router, "DELETE", api ~ "/bindings/legacy-admin/policy", Json.undefined, status);
  assert(status == 200);
  call(router, "POST", api ~ "/scaling-events", Json.emptyObject, status);
  assert(status == 405);

  // OData
  auto meta = call(router, "GET", od ~ "/$metadata", Json.undefined, status);
  assert(status == 200 && meta.get!string.canFind("uim.autoscaler") && meta.get!string.canFind("EvaluationResult"));
  auto stats = call(router, "GET", od ~ "/Statistics", Json.undefined, status);
  assert(status == 200 && stats["bindings"].get!long == 5 && stats["policies"].get!long == 4, stats.toString);
  auto rules = call(router, "GET", od ~ "/Rules?$filter=policyId eq 'web-standard'&$count=true", Json.undefined, status);
  assert(status == 200 && rules["@odata.count"].get!long == 3, rules.toString);
  auto sched = call(router, "GET", od ~ "/Schedules?$filter=active eq true", Json.undefined, status);
  assert(status == 200 && sched["value"].length == 1 && sched["value"][0]["daysText"].get!string == "Mon–Fri", sched.toString);
  auto act = call(router, "POST", od ~ "/ActivatePolicy", Json(["id": Json("reporting")]), status);
  assert(status == 200 && act["status"].get!string == "active", act.toString);
  call(router, "POST", od ~ "/ActivatePolicy", Json(["id": Json("reporting")]), status);
  assert(status == 422);
  auto summary = call(router, "POST", od ~ "/EvaluateAll", Json.emptyObject, status);
  assert(status == 200 && summary["evaluated"].get!long == 4, summary.toString);
  auto purge = call(router, "POST", od ~ "/PurgeMetrics", Json.emptyObject, status);
  assert(status == 200 && purge["samples"].get!long == 0, purge.toString);
  auto health = call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200 && health["status"].get!string == "UP" && health["instanceController"].get!string == "simulate");
  auto caps = call(router, "GET", api ~ "/capabilities", Json.undefined, status);
  assert(status == 200 && caps["metricTypes"].length == 9);
}

/// Built-in login (authMode jwt): tokens and the scopes Read / Operate / Manage / Admin.
unittest {
  auto b = newBed(["authMode": Json("jwt"), "jwtSecret": Json("0123456789abcdef0123456789abcdef"),
      "maxFailedLogins": Json(3)]);
  auto c = b.c;
  assert(c.security.mode == "jwt" && c.security.loginEnabled && !c.security.generatedSecret);
  assert(c.ports.users.ensureAdministrator(t, "admin", "admin password 1"));
  assert(!c.ports.users.ensureAdministrator(t, "admin2", "admin password 2"));
  auto router = routerOf(c);
  int status;
  enum api = "/api/v1/autoscaler";
  enum od = "/odata/v4/autoscaler";

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", api ~ "/bindings", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", od ~ "/Bindings", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200); // probes stay public
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);
  call(router, "POST", "/auth/login", Json(["username": Json("ghost"), "password": Json("wrong")]), status);
  assert(status == 401);

  auto login = call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("admin password 1")]), status);
  assert(status == 200 && login["scope"].get!string == "Read Operate Manage Admin", login.toString);
  auto admin = login["access_token"].get!string;
  call(router, "POST", api ~ "/demo-data", Json.emptyObject, status, "application/json", "", admin);
  assert(status == 200);
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, "application/json", "", admin);
  assert(status == 200 && me["user"].get!string == "admin" && me["scopes"].length == 4);

  // an operator (Operate) and a viewer (Read)
  call(router, "POST", od ~ "/Users", Json(["id": Json("ops"), "password": Json("operator password"),
      "scopes": Json([Json("Operate")])]), status, "application/json", "", admin);
  assert(status == 201);
  call(router, "POST", od ~ "/Users", Json(["id": Json("viewer"), "password": Json("viewer password"),
      "scopes": Json([Json("Read")])]), status, "application/json", "", admin);
  assert(status == 201);
  auto op = call(router, "POST", "/auth/login", Json.undefined, status, "application/x-www-form-urlencoded",
    "username=ops&password=operator%20password", "");
  assert(status == 200 && op["scope"].get!string == "Read Operate", op.toString);
  auto ops = op["access_token"].get!string;
  auto viewer = call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("viewer password")]),
    status)["access_token"].get!string;

  // Read: everything visible, nothing changes
  call(router, "GET", od ~ "/ScalingEvents", Json.undefined, status, "application/json", "", viewer);
  assert(status == 200);
  call(router, "POST", od ~ "/EvaluateBinding", Json(["id": Json("order-service")]), status, "application/json", "", viewer);
  assert(status == 403);
  call(router, "POST", api ~ "/apps/7b91e4aa-order-service/metrics", Json(["metricName": Json("cpu"), "value": Json(1)]),
    status, "application/json", "", viewer);
  assert(status == 403);
  // Operate: metrics, evaluations, manual scaling — but no policies or users
  auto ev = call(router, "POST", api ~ "/bindings/order-service/evaluate", Json.emptyObject, status, "application/json", "", ops);
  assert(status == 200 && ev["status"].get!string == "succeeded", ev.toString);
  auto ev2 = call(router, "POST", api ~ "/bindings/order-service/scale", Json(["instances": Json(5)]), status,
    "application/json", "", ops);
  assert(status == 200 && c.ports.scaling.getEvent(t, ScalingEventId(ev2["eventId"].get!string)).createdBy.value == "ops");
  call(router, "POST", api ~ "/apps/7b91e4aa-order-service/metrics", Json(["metricName": Json("cpu"), "value": Json(12)]),
    status, "application/json", "", ops);
  assert(status == 201);
  call(router, "POST", api ~ "/policies/reporting/activate", Json.emptyObject, status, "application/json", "", ops);
  assert(status == 403);
  call(router, "DELETE", api ~ "/bindings/legacy-admin", Json.undefined, status, "application/json", "", ops);
  assert(status == 403);
  call(router, "GET", od ~ "/Users", Json.undefined, status, "application/json", "", ops);
  assert(status == 403);

  // password change, lockout, the last administrator, tampered tokens
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("viewer password"), "newPassword": Json("a better password")]),
    status, "application/json", "", viewer);
  assert(status == 204);
  foreach (_; 0 .. 3)
    call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("nope")]), status);
  auto locked = call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("a better password")]), status);
  assert(status == 401 && locked["error"]["message"].get!string.canFind("locked"), locked.toString);
  assert(failsWith(AasErrorKind.ruleViolation, () { c.ports.users.deleteUser(t, UserAccountId("admin"), UserId("ops")); }));
  call(router, "GET", api ~ "/bindings", Json.undefined, status, "application/json", "", admin[0 .. $ - 2] ~ "xx");
  assert(status == 401);
  assert(c.ports.users.issueToken(t, UserAccountId("ops")).accessToken.length > 20);
}

/// The command line adapter.
unittest {
  auto b = newBed();
  string out_;
  auto cli = buildAasCli(b.c, (string s) @safe { out_ ~= s; });
  assert(cli.run(["seed", "--json"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // not empty
  assert(cli.run(["stats"]) == 0 && cli.run(["list", "Bindings"]) == 0 && cli.run(["sets"]) == 0);
  out_ = "";
  assert(cli.run(["evaluate", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["scaledOut"].get!long == 3, out_);
  assert(cli.run(["bind", "cli-app", "guid-cli", "--policy=web-standard", "--instances=2", "--id=cli-app"]) == 0, out_);
  assert(cli.run(["simulate", "cli-app", "cpu", "97", "--seconds=240"]) == 0, out_);
  out_ = "";
  assert(cli.run(["preview", "cli-app", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["newInstances"].get!long == 3, out_); // below the schedule minimum first
  assert(cli.run(["evaluate", "cli-app"]) == 0 && cli.run(["metric", "cli-app", "cpu", "50"]) == 0);
  assert(cli.run(["scale", "cli-app", "7", "load test"]) == 0 && cli.run(["history", "cli-app"]) == 0, out_);
  assert(cli.run(["suspend", "cli-app"]) == 0 && cli.run(["suspend", "cli-app"]) == 1 && cli.run(["resume", "cli-app"]) == 0);
  assert(cli.run(["detach", "cli-app"]) == 0 && cli.run(["attach", "cli-app", "batch-workers"]) == 0);
  assert(cli.run(["rules", "web-standard"]) == 0 && cli.run(["schedules", "batch-workers"]) == 0);
  assert(cli.run(["activate", "reporting"]) == 0 && cli.run(["deactivate", "reporting"]) == 0);
  assert(cli.run(["purge"]) == 0 && cli.run(["capabilities"]) == 0 && cli.run(["config"]) == 0);
  assert(cli.run(["scale", "cli-app", "500"]) == 1);
  assert(cli.run(["token", "admin"]) == 1); // authMode open: no issuer
}

/// Batching file store: an evaluation run writes the snapshot once; a
/// second container (the CLI next to the server) sees the data.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;
  import std.uuid : randomUUID;

  auto file = buildPath(tempDir, "uim-aas-" ~ randomUUID.toString, "data.json");
  scope (exit)
    if (exists(dirName(file)))
      rmdirRecurse(dirName(file));
  auto storage = createStorage("file", file);
  auto b = newBed(null, storage);
  seedDemoData(b.c.ports, t, actor);
  auto store = cast(BatchingFileDocumentStore) storage.store;
  auto before = store.flushes;
  auto s = b.c.ports.scaling.evaluateAll(t, actor);
  assert(s.scaledOut == 3 && store.flushes == before + 1, (store.flushes - before).to!string);

  Json[string] o;
  o["storage"] = "file";
  o["dataFile"] = file;
  auto other = new AasContainer(loadAasConfig(o, "/nonexistent"));
  other.events.log = false;
  assert(other.ports.bindings.list(t).length == 5 && other.ports.scaling.listEvents(t).length == 3);
  assert(other.ports.bindings.get(t, AppBindingId("invoice-worker")).currentInstances == 3);
}

/// The scaling worker never throws and counts its runs.
unittest {
  auto b = newBed();
  seedDemoData(b.c.ports, t, actor);
  auto w = new ScalingWorker(b.c.ports, ["default", "empty"], 1, b.c.metrics);
  auto s = w.runOnce();
  assert(s.scaledOut == 3 && b.c.metrics.runs == 1 && b.c.metrics.errors == 0);
  assert(w.runOnce().scaledOut == 0 && b.c.metrics.runs == 2);
}
