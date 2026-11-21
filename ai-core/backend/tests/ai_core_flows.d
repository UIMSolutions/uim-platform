/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the runtime lifecycle
/// through the ports with a manual clock, management through the OData
/// engine, the AI API v2 over vibe.d test requests and the file store.
module tests.ai_core_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.ai_core;

@safe:

version (unittest) {
  enum long t0 = 639_000_000_000_000_000; // 2026-01-31 (std time), fixed for deterministic cron tests

  AiCoreContainer newContainer(ManualClock clock, IDocumentStore store = null) {
    Json[string] o;
    o["storage"] = "memory";
    o["executionStartSeconds"] = 1;
    o["executionRunSeconds"] = 10;
    o["deploymentStartSeconds"] = 2;
    auto c = new AiCoreContainer(loadAiCoreConfig(o, "/nonexistent"), store, clock);
    c.events.log = false;
    return c;
  }

  RequestContext admin(string tenant = "default") {
    return RequestContext.local(tenant, "test", "admin");
  }

  int statusOf(scope void delegate() @safe dg) {
    try
      dg();
    catch (EntitySetException e)
      return e.status;
    return 0;
  }

  /// One AI API call through the router.
  Json call(URLRouter router, string method, string path, Json body, out int status, string group = "default") @trusted {
    InetHeaderMap headers;
    if (group.length)
      headers["AI-Resource-Group"] = group;
    headers["Content-Type"] = "application/json";
    auto text = body.type == Json.Type.undefined ? "" : body.toString;
    auto req = createTestHTTPServerRequest(URL("http://localhost" ~ path), httpMethodFromString(method), headers,
      createMemoryStream(cast(ubyte[]) text.dup, false));
    auto output = createMemoryOutputStream();
    auto res = createTestHTTPServerResponse(output, null, TestHTTPResponseMode.bodyOnly);
    router.handleRequest(req, res);
    status = res.statusCode;
    auto answer = cast(string) output.data;
    return answer.strip.length ? parseJsonString(answer) : Json(null);
  }
}

/// Lifecycle: seed → executions run and complete (with output artifacts),
/// deployments start and expire, schedules fire on their cron slot.
unittest {
  auto clock = new ManualClock(t0);
  auto c = newContainer(clock);
  auto t = TenantId("default"), rg = ResourceGroupId("default");
  auto seeded = seedDemoData(c.ports, t, UserId("admin"));
  assert(seeded.resourceGroups == 2 && seeded.executions == 2 && seeded.deployments == 1 && seeded.metrics == 10);

  auto runs = c.ports.executions.listExecutions(t, rg);
  assert(runs.length == 1 && runs[0].status == ExecutionStatus.pending);
  assert(c.ports.reconciler.reconcile(t).total == 0); // nothing due yet

  clock.advance(2);
  auto r = c.ports.reconciler.reconcile(t);
  assert(r.executionsStarted == 2 && r.deploymentsStarted == 1, r.to!string);
  auto dep = c.ports.deployments.listDeployments(t, rg)[0];
  assert(dep.status == DeploymentStatus.running && dep.deploymentUrl.endsWith("/deployments/" ~ dep.id.value));
  assert(dep.latestRunningConfigurationId.value == "serve-v1");

  // running executions block deletion of their group
  assert(failsWith(AiCoreErrorKind.ruleViolation, () { c.ports.resourceGroups.deleteResourceGroup(t, rg); }));
  assert(failsWith(AiCoreErrorKind.ruleViolation, () { c.ports.executions.deleteExecution(t, rg, runs[0].id); }));

  clock.advance(10);
  r = c.ports.reconciler.reconcile(t);
  assert(r.executionsCompleted == 2 && r.artifactsCreated == 3, r.to!string); // model + evaluation + forecast
  auto done = c.ports.executions.getExecution(t, rg, runs[0].id);
  assert(done.status == ExecutionStatus.completed && done.outputArtifacts.length == 2);
  auto model = c.ports.artifacts.getArtifact(t, rg, done.outputArtifacts[0].artifactId);
  assert(model.kind == ArtifactKind.model && model.executionId == done.id && model.url.startsWith("ai://"));
  assert(done.tags.labelValue("dataset-version") == "2026-06");

  // the new model can be served by a new configuration
  CreateConfigurationRequest cfg;
  cfg.tenantId = t;
  cfg.resourceGroupId = rg;
  cfg.name = "Serve retrained";
  cfg.scenarioId = "text-classification";
  cfg.executableId = "text-clf-serve";
  cfg.inputArtifactBindings = [ArtifactRef("model", model.id)];
  auto v2 = c.ports.configurations.createConfiguration(cfg);
  PatchDeploymentRequest roll;
  roll.tenantId = t;
  roll.resourceGroupId = rg;
  roll.id = dep.id.value;
  roll.configurationId = v2.id.value;
  dep = c.ports.deployments.patchDeployment(roll);
  assert(dep.status == DeploymentStatus.pending && dep.lastOperation == DeploymentOperation.update);
  clock.advance(2);
  c.ports.reconciler.reconcile(t);
  dep = c.ports.deployments.getDeployment(t, rg, dep.id);
  assert(dep.status == DeploymentStatus.running && dep.latestRunningConfigurationId == v2.id);

  // stop → stopping → stopped → deletable
  PatchDeploymentRequest stop;
  stop.tenantId = t;
  stop.resourceGroupId = rg;
  stop.id = dep.id.value;
  stop.targetStatus = "STOPPED";
  assert(c.ports.deployments.patchDeployment(stop).status == DeploymentStatus.stopping);
  assert(failsWith(AiCoreErrorKind.ruleViolation, () { c.ports.deployments.deleteDeployment(t, rg, dep.id); }));
  c.ports.reconciler.reconcile(t);
  c.ports.deployments.deleteDeployment(t, rg, dep.id);

  // TTL
  CreateDeploymentRequest ttl;
  ttl.tenantId = t;
  ttl.resourceGroupId = rg;
  ttl.configurationId = "serve-v1";
  ttl.ttlSeconds = 600;
  auto short_ = c.ports.deployments.createDeployment(ttl);
  clock.advance(2);
  c.ports.reconciler.reconcile(t);
  clock.advance(600);
  assert(c.ports.reconciler.reconcile(t).deploymentsExpired == 1);
  assert(c.ports.deployments.getDeployment(t, rg, short_.id).status == DeploymentStatus.stopped);
  ttl.ttlSeconds = 30;
  assert(failsWith(AiCoreErrorKind.invalid, () { c.ports.deployments.createDeployment(ttl); }));

  // the nightly schedule fires at 02:00 UTC
  auto schedule = c.ports.schedules.getSchedule(t, rg, ScheduleId("nightly-retraining"));
  assert(isoTimeText(schedule.nextRunAt).endsWith("T02:00:00Z"));
  clock.current = schedule.nextRunAt;
  assert(c.ports.reconciler.reconcile(t).schedulesFired == 1);
  schedule = c.ports.schedules.getSchedule(t, rg, schedule.id);
  assert(!schedule.lastExecutionId.isNull && secondsBetween(schedule.lastRunAt, schedule.nextRunAt) == 86_400);
  assert(c.ports.executions.getExecution(t, rg, schedule.lastExecutionId).scheduleId == schedule.id);

  // workflow vs serving
  CreateExecutionRequest wrong;
  wrong.tenantId = t;
  wrong.resourceGroupId = rg;
  wrong.configurationId = "serve-v1";
  assert(failsWith(AiCoreErrorKind.ruleViolation, () { c.ports.executions.createExecution(wrong); }));

  // referential integrity
  assert(failsWith(AiCoreErrorKind.ruleViolation, () {
      c.ports.configurations.deleteConfiguration(t, rg, ConfigurationId("train-default"));
    }));
  assert(failsWith(AiCoreErrorKind.ruleViolation, () {
      c.ports.artifacts.deleteArtifact(t, rg, ArtifactId("support-tickets-2026"));
    }));
  assert(failsWith(AiCoreErrorKind.ruleViolation, () {
      c.ports.scenarios.deleteScenario(t, rg, ScenarioId("text-classification"));
    }));

  // the group can be deleted once nothing runs
  clock.advance(60);
  c.ports.reconciler.reconcile(t);
  auto forecast = ResourceGroupId("team-forecast");
  assert(c.ports.resourceGroups.deleteResourceGroup(t, forecast) >= 4);
  assert(c.ports.scenarios.listScenarios(t, forecast).length == 0);

  auto stats = c.ports.statistics.compute(t);
  assert(stats.resourceGroups == 1 && stats.completedExecutions == 1 && stats.activeSchedules == 1, stats.to!string);
}

/// OData engine: composite keys, validation and error mapping, tenant isolation.
unittest {
  auto clock = new ManualClock(t0);
  auto c = newContainer(clock);
  auto e = c.engine;
  assert(e.invoke(admin, "SeedDemoData", Json.emptyObject)["scenarios"].get!long == 2);

  auto scenario = e.read(admin, "Scenarios", "default~text-classification");
  assert(scenario["executableCount"].get!long == 2 && scenario["artifactCount"].get!long == 2);
  assert(statusOf(() { e.read(admin, "Scenarios", "text-classification"); }) == 404); // not a composite key
  assert(statusOf(() { e.read(admin("other"), "Scenarios", "default~text-classification"); }) == 404); // isolation

  // create executable + configuration through OData text forms
  e.create(admin, "Executables", Json([
      "resourceGroupId": Json("default"), "id": Json("tiny-train"), "scenarioId": Json("text-classification"),
      "name": Json("Tiny"), "type": Json("workflow"), "parameters": Json([Json("epochs=1"), Json("seed")]),
      "outputArtifacts": Json([Json("model:model")])
    ]));
  assert(statusOf(() {
      e.create(admin, "Configurations", Json([
        "resourceGroupId": Json("default"), "name": Json("missing seed"), "scenarioId": Json("text-classification"),
        "executableId": Json("tiny-train")
      ]));
    }) == 400);
  auto cfg = e.create(admin, "Configurations", Json([
      "resourceGroupId": Json("default"), "name": Json("tiny"), "scenarioId": Json("text-classification"),
      "executableId": Json("tiny-train"), "parameterBindings": Json([Json("seed=42")])
    ]));
  assert(cfg["executableType"].get!string == "workflow" && cfg["key"].get!string.startsWith("default~"));
  assert(statusOf(() { e.update(admin, "Configurations", cfg["key"].get!string, Json(["name": Json("x")])); }) == 405);

  auto run = e.create(admin, "Executions", Json(["resourceGroupId": Json("default"), "configurationId": cfg["id"]]));
  assert(run["status"].get!string == "PENDING");
  auto stopped = e.invoke(admin, "StopExecution", Json(["key": run["key"]]));
  assert(stopped["status"].get!string == "STOPPED");
  assert(statusOf(() { e.invoke(admin, "StopExecution", Json(["key": run["key"]])); }) == 0); // idempotent
  e.remove(admin, "Executions", run["key"].get!string);

  // conflicts and rule violations
  assert(statusOf(() {
      e.create(admin, "ResourceGroups", Json(["id": Json("default")]));
    }) == 409);
  assert(statusOf(() {
      e.create(admin, "ResourceGroups", Json(["id": Json("Bad_Group")]));
    }) == 400);
  assert(statusOf(() { e.remove(admin, "Executables", "default~text-clf-train"); }) == 422);
  assert(statusOf(() {
      e.create(admin, "ExecutionSchedules", Json([
        "resourceGroupId": Json("default"), "configurationId": Json("train-default"), "cron": Json("61 * * * *")
      ]));
    }) == 400);

  // secrets never leave the service
  auto secret = e.read(admin, "DockerRegistrySecrets", "acme-registry");
  assert(secret["password"].type == Json.Type.null_ && secret["hasCredentials"].get!bool);
  assert(!c.store.get("aicore.dockerRegistrySecrets", "default", "acme-registry").toString.canFind("demo-password"));

  // metrics
  auto execution = e.query(admin, "Executions", ["$filter": "configurationId eq 'train-default'"]).rows[0];
  auto metric = e.create(admin, "Metrics", Json([
      "resourceGroupId": Json("default"), "executionId": execution["id"], "name": Json("f1"), "value": Json(0.91),
      "step": Json(9)
    ]));
  assert(metric["value"].get!double == 0.91);
  assert(e.read(admin, "Executions", execution["key"].get!string)["metricCount"].get!long == 11);
  assert(e.invoke(admin, "ClearMetrics", Json(["key": execution["key"]]))["count"].get!long == 11);

  auto stats = e.read(admin, "Statistics", "");
  assert(stats["scenarios"].get!long == 2 && stats["secrets"].get!long == 2);
}

/// AI API v2 over HTTP: headers, envelopes, status codes, bulk PATCH, metrics.
unittest {
  auto clock = new ManualClock(t0);
  auto c = newContainer(clock);
  auto router = new URLRouter;
  new AiApiController(c.ports, new SecuritySetup, "/api/v2", "default", "2.0.0").registerRoutes(router);
  int status;

  auto meta = call(router, "GET", "/api/v2/lm/meta", Json.undefined, status, "");
  assert(status == 200 && meta["aiApi"]["capabilities"]["executionSchedules"].get!bool);

  // the default group is created on first use
  auto sc = call(router, "POST", "/api/v2/lm/scenarios", Json(["id": Json("churn"), "name": Json("Churn")]), status);
  assert(status == 201 && sc["id"].get!string == "churn", sc.toString);
  call(router, "POST", "/api/v2/lm/scenarios/churn/executables", Json([
      "id": Json("churn-train"), "name": Json("Train"), "deployable": Json(false),
      "parameters": Json([Json(["name": Json("depth"), "default": Json("6")])]),
      "outputArtifacts": Json([Json(["name": Json("model"), "kind": Json("model")])])
    ]), status);
  assert(status == 201);
  auto list = call(router, "GET", "/api/v2/lm/scenarios/churn/executables", Json.undefined, status);
  assert(status == 200 && list["count"].get!long == 1 && list["resources"][0]["parameters"][0]["default"].get!string == "6");

  auto cfg = call(router, "POST", "/api/v2/lm/configurations", Json([
      "name": Json("churn-cfg"), "scenarioId": Json("churn"), "executableId": Json("churn-train"),
      "parameterBindings": Json([Json(["key": Json("depth"), "value": Json("8")])])
    ]), status);
  assert(status == 201, cfg.toString);
  auto cfgId = cfg["id"].get!string;

  string[] ids;
  foreach (_; 0 .. 3) {
    auto ex = call(router, "POST", "/api/v2/lm/executions", Json(["configurationId": Json(cfgId)]), status);
    assert(status == 202 && ex["status"].get!string == "PENDING", ex.toString);
    ids ~= ex["id"].get!string;
  }
  auto count = call(router, "GET", "/api/v2/lm/executions/$count", Json.undefined, status);
  assert(status == 200 && count.get!long == 3);
  auto page = call(router, "GET", "/api/v2/lm/executions?$top=2&$skip=1", Json.undefined, status);
  assert(page["count"].get!long == 3 && page["resources"].length == 2 && page["resources"][0]["configurationName"].get!string == "churn-cfg");

  // metrics + tags
  call(router, "PATCH", "/api/v2/lm/metrics", Json([
      "executionId": Json(ids[0]),
      "metrics": Json([Json(["name": Json("auc"), "value": Json(0.81), "step": Json(1)])]),
      "tags": Json([Json(["name": Json("team"), "value": Json("crm")])])
    ]), status);
  assert(status == 204);
  auto metrics = call(router, "GET", "/api/v2/lm/metrics?executionIds=" ~ ids[0], Json.undefined, status);
  assert(metrics["resources"][0]["metrics"][0]["value"].get!double == 0.81);
  assert(metrics["resources"][0]["tags"][0]["value"].get!string == "crm");

  // bulk stop: two existing, one unknown
  auto bulk = call(router, "PATCH", "/api/v2/lm/executions", Json(["executions": Json([
      Json(["id": Json(ids[1]), "targetStatus": Json("STOPPED")]), Json(["id": Json(ids[2]), "targetStatus": Json("STOPPED")]),
      Json(["id": Json("nope"), "targetStatus": Json("STOPPED")])
    ])]), status);
  assert(status == 202 && bulk["executions"].length == 3 && "error" in bulk["executions"][2], bulk.toString);
  auto single = call(router, "GET", "/api/v2/lm/executions/" ~ ids[1], Json.undefined, status);
  assert(single["status"].get!string == "STOPPED" && single["targetStatus"].get!string == "STOPPED");

  // errors
  call(router, "GET", "/api/v2/lm/executions/missing", Json.undefined, status);
  assert(status == 404);
  auto pending = call(router, "DELETE", "/api/v2/lm/executions/" ~ ids[0], Json.undefined, status);
  assert(status == 412 && pending["error"]["message"].get!string.canFind("PENDING"), pending.toString);
  call(router, "POST", "/api/v2/lm/deployments", Json(["configurationId": Json(cfgId)]), status);
  assert(status == 412); // workflow executable
  call(router, "GET", "/api/v2/lm/scenarios", Json.undefined, status, "no-such-group");
  assert(status == 200); // lists of an unknown group are empty
  call(router, "POST", "/api/v2/lm/scenarios", Json(["id": Json("x")]), status, "no-such-group");
  assert(status == 404);
  call(router, "POST", "/api/v2/lm/configurations", Json(["name": Json("broken")]), status);
  assert(status == 404 || status == 400);

  // reconcile and read the produced artifact
  clock.advance(1);
  c.ports.reconciler.reconcile(TenantId("default"));
  clock.advance(10);
  c.ports.reconciler.reconcile(TenantId("default"));
  auto ex0 = call(router, "GET", "/api/v2/lm/executions/" ~ ids[0], Json.undefined, status);
  assert(ex0["status"].get!string == "COMPLETED" && ex0["outputArtifacts"][0]["kind"].get!string == "model", ex0.toString);
  auto models = call(router, "GET", "/api/v2/lm/artifacts?kind=model", Json.undefined, status);
  assert(models["count"].get!long == 1);

  // admin API
  auto group = call(router, "POST", "/api/v2/admin/resourceGroups", Json([
      "resourceGroupId": Json("team-b"), "labels": Json([Json(["key": Json("ext.ai.sap.com/owner"), "value": Json("b")])])
    ]), status, "");
  assert(status == 202 && group["resourceGroupId"].get!string == "team-b");
  auto groups = call(router, "GET", "/api/v2/admin/resourceGroups", Json.undefined, status, "");
  assert(groups["count"].get!long == 2);
  call(router, "POST", "/api/v2/admin/dockerRegistrySecrets", Json([
      "name": Json("hub"), "data": Json([".dockerconfigjson": Json(`{"auths":{"docker.io":{"username":"u","password":"p"}}}`)])
    ]), status, "");
  assert(status == 201);
  auto hub = call(router, "GET", "/api/v2/admin/dockerRegistrySecrets/hub", Json.undefined, status, "");
  assert(hub["server"].get!string == "docker.io" && "password" !in hub);
  call(router, "DELETE", "/api/v2/admin/resourceGroups/team-b", Json.undefined, status, "");
  assert(status == 202);
}

/// Security: with authentication required, reads need "Read" and writes "Manage".
unittest {
  import uim.platform.service.infrastructure.security.context : Hs256TokenVerifier;

  auto c = newContainer(new ManualClock(t0));
  auto security = new SecuritySetup;
  security.requireAuthentication = true;
  security.verifier = new Hs256TokenVerifier("0123456789abcdef0123456789abcdef");
  auto router = new URLRouter;
  new AiApiController(c.ports, security).registerRoutes(router);
  int status;
  call(router, "GET", "/api/v2/lm/scenarios", Json.undefined, status);
  assert(status == 401);
}

/// File store: a second container (e.g. the CLI) sees the server's data.
unittest {
  import std.file : tempDir, remove, exists;
  import std.path : buildPath;

  auto path = buildPath(tempDir, "uim-ai-core-test-" ~ newResourceId() ~ ".json");
  scope (exit)
    if (exists(path))
      remove(path);
  auto clock = new ManualClock(t0);
  auto first = newContainer(clock, new FileDocumentStore(path));
  seedDemoData(first.ports, TenantId("default"), UserId("admin"));
  auto second = newContainer(clock, new FileDocumentStore(path));
  auto e = second.ports.executables.getExecutable(TenantId("default"), ResourceGroupId("default"), ExecutableId("text-clf-train"));
  assert(e.parameters.length == 3 && e.outputArtifacts.length == 2 && e.versionId == "1.2.0");
  assert(second.ports.statistics.compute(TenantId("default")).metrics == 10);
}
