/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the demo content, the ML
/// life cycle through the ports (connection → scenario → configuration →
/// execution / deployment → reconciliation with the simulated runtime), the
/// registry and generative AI hub rules, the launchpad tiles, users and
/// roles, the persistent audit log, the REST API and the OData endpoint
/// over vibe.d test requests with the built-in JWT login, and the CLI.
module tests.launchpad_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.ai_launchpad;

@safe:

version (unittest) {
  /// 2026-11-27T10:00:00Z
  long t0() {
    return parseIsoTime("2026-11-27T10:00:00Z");
  }

  struct TestBed {
    AilpContainer c;
    ManualClock clock;
  }

  TestBed newBed(Json[string] extra = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["reconcileIntervalSeconds"] = 0;
    o["passwordIterations"] = 1000;
    o["simulatedDeploymentSeconds"] = 0;
    foreach (k, v; extra)
      o[k] = v;
    TestBed b;
    b.clock = new ManualClock(t0);
    b.c = new AilpContainer(loadAilpConfig(o, "/nonexistent"), storage, b.clock);
    b.c.audit.log = false;
    b.c.bootstrapTenant("default");
    return b;
  }

  /// One HTTP call through the router; text bodies are sent as is.
  Json call(URLRouter router, string method, string path, Json body, out int status, string bearer = "") @trusted {
    InetHeaderMap headers;
    headers["Content-Type"] = "application/json";
    if (bearer.length)
      headers["Authorization"] = "Bearer " ~ bearer;
    auto payload = body.type == Json.Type.undefined ? "" : body.toString;
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

  URLRouter routerOf(AilpContainer c) {
    c.engine.enforceScopes = c.security.requireAuthentication; // as in app.d
    auto router = new URLRouter;
    new AilpHealthController(c.config, c.security.mode, c.runtime.mode, c.metrics).registerRoutes(router, c.config.apiPath);
    new AuthController(c.ports, c.security).registerRoutes(router);
    new AilpApiController(c.engine, c.ports, c.security, "/api/v1", "2.0.0", 4 * 1024 * 1024,
      capabilitiesJson(c.runtime.mode, c.config.policy)).registerRoutes(router);
    auto odata = new ODataController(c.engine, "/odata/v4/ai-launchpad");
    odata.verifier = c.security.verifier;
    odata.requireAuthentication = c.security.requireAuthentication;
    odata.registerRoutes(router);
    return router;
  }

  auto t = TenantId("default");
  auto actor = UserId("tester");

  /// Workspace W, a valid connection C with resource group "default", scenario S
  /// (training, serving), dataset D and the configurations "train" and "serve".
  void miniLandscape(AilpContainer c) {
    c.ports.workspaces.create(createCommand(t, actor, "W", WorkspaceInput("Workspace W", "", "active")));
    ConnectionInput ci;
    ci.workspaceId = "W";
    ci.name = "C";
    ci.url = "https://api.ai.example.com/v2";
    ci.authUrl = "https://auth.example.com/oauth/token";
    ci.clientId = "client";
    ci.clientSecret = "secret";
    c.ports.connections.create(createCommand(t, actor, "C", ci));
    c.ports.resourceGroups.create(createCommand(t, actor, "default", ResourceGroupInput("C", "", [], "ready")));
    c.ports.scenarios.create(createCommand(t, actor, "S", ScenarioInput("C", "Scenario S", "", ["training", "serving"], [])));
    DatasetInput d;
    d.scenarioId = "S";
    d.name = "D";
    d.url = "s3://bucket/d.csv";
    c.ports.datasets.create(createCommand(t, actor, "D", d));
    c.ports.configurations.create(createCommand(t, actor, "train", ConfigurationInput("S", "Train", "training", [
          "epochs=3"
        ], ["data=D"])));
    c.ports.configurations.create(createCommand(t, actor, "serve", ConfigurationInput("S", "Serve", "serving", [], [])));
  }
}

/// The demo content: two workspaces, a valid and a broken connection, running workloads, prompts.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto r = seedDemoData(c.ports, t, actor);
  assert(r.workspaces == 2 && r.connections == 2 && r.scenarios == 2 && r.configurations == 3 && r.prompts == 3);
  assert(failsWith(AilpErrorKind.ruleViolation, () { seedDemoData(c.ports, t, actor); }), "only once");
  assert(c.ports.connections.get(t, ConnectionId("aicore-eu")).isActive);
  auto legacy = c.ports.connections.get(t, ConnectionId("aicore-legacy"));
  assert(legacy.status == ConnectionStatus.error && legacy.statusMessage.canFind("not reachable"), legacy.statusMessage);
  assert(c.ports.executions.list(t).all!(e => e.status == ExecutionStatus.running));
  assert(c.ports.deployments.get(t, DeploymentId("fraud-api")).status == DeploymentStatus.running);

  auto s = c.ports.statistics.compute(t);
  assert(s.runningExecutions == 2 && s.runningDeployments == 1 && s.activeConnections == 1 && s.roles == 5, s.to!string);
  assert(s.tiles == defaultTiles.length && s.logEntriesLast24h > 10 && s.warningsLast24h >= 1);

  // a minute later the fraud training completes, the forecast fails (simulate.outcome=failed)
  b.clock.advance(61);
  auto rec = c.ports.reconciler.reconcile(t, actor);
  assert(rec.completed == 1 && rec.failed == 1 && rec.messages.length == 1, rec.summary);
  assert(c.ports.statistics.compute(t).failedExecutions == 1);
}

/// The life cycle: validation, resource groups, executions, deployments and the reconciliation.
unittest {
  auto b = newBed();
  auto c = b.c;
  miniLandscape(c);
  auto exec = createCommand(t, actor, "e1", ExecutionInput("train", ""));
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.executions.create(exec); }), "connection not validated");
  assert(c.ports.connections.validateConnection(t, ConnectionId("C"), actor).isActive);

  auto e = c.ports.executions.create(exec);
  assert(e.status == ExecutionStatus.pending && e.resourceGroupId.value == "default" && e.scenarioId.value == "S");
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.executions.remove(t, ExecutionId("e1"), actor); }));
  // the configuration is in use now: immutable
  auto change = updateCommand(t, actor, "train", ConfigurationInput("", "", "", ["epochs=5"], []), "parameters");
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.configurations.update(change); }));

  auto r1 = c.ports.reconciler.reconcile(t, actor);
  assert(r1.started == 1 && c.ports.executions.get(t, ExecutionId("e1")).status == ExecutionStatus.running);
  b.clock.advance(30);
  assert(c.ports.reconciler.reconcile(t, actor).changes == 0);
  b.clock.advance(30);
  assert(c.ports.reconciler.reconcile(t, actor).completed == 1);
  e = c.ports.executions.get(t, ExecutionId("e1"));
  assert(e.status == ExecutionStatus.completed && e.durationSeconds == 60, e.to!string);

  // a model of the completed execution; name + version unique per scenario
  ModelInput m;
  m.scenarioId = "S";
  m.executionId = "e1";
  m.name = "model";
  m.url = "ai://default/models/model";
  c.ports.models.create(createCommand(t, actor, "m1", m));
  assert(failsWith(AilpErrorKind.conflict, () { c.ports.models.create(createCommand(t, actor, "m2", m)); }));
  m.version_ = "2";
  m.executionId = "ghost";
  assert(failsWith(AilpErrorKind.notFound, () { c.ports.models.create(createCommand(t, actor, "m2", m)); }));

  // deployments: running after the first poll, stop, restart, TTL
  DeploymentInput di;
  di.configurationId = "serve";
  di.maxReplicas = 2;
  di.ttlMinutes = 10;
  c.ports.deployments.create(createCommand(t, actor, "d1", di));
  assert(c.ports.reconciler.reconcile(t, actor).deployed == 1);
  auto d = c.ports.deployments.get(t, DeploymentId("d1"));
  assert(d.status == DeploymentStatus.running && d.deploymentUrl == "https://api.ai.example.com/v2/inference/deployments/d1");
  di.maxReplicas = 11;
  assert(failsWith(AilpErrorKind.invalid, () {
      c.ports.deployments.update(updateCommand(t, actor, "d1", di, "maxReplicas"));
    }));
  // the resource group cannot be disabled or deleted while workloads are active
  assert(failsWith(AilpErrorKind.ruleViolation, () {
      c.ports.resourceGroups.update(updateCommand(t, actor, "default", ResourceGroupInput("", "", [], "disabled"), "status"));
    }));
  b.clock.advance(10 * 60);
  assert(c.ports.reconciler.reconcile(t, actor).expired == 1);
  assert(c.ports.deployments.get(t, DeploymentId("d1")).status == DeploymentStatus.stopped);
  c.ports.deployments.start(t, DeploymentId("d1"), actor);
  assert(c.ports.deployments.get(t, DeploymentId("d1")).status == DeploymentStatus.pending);
  c.ports.deployments.stop(t, DeploymentId("d1"), actor);
  c.ports.deployments.remove(t, DeploymentId("d1"), actor);

  // stop a running execution
  c.ports.executions.create(createCommand(t, actor, "e2", ExecutionInput("train", "default")));
  c.ports.reconciler.reconcile(t, actor);
  assert(c.ports.executions.stop(t, ExecutionId("e2"), actor).status == ExecutionStatus.stopped);
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.executions.stop(t, ExecutionId("e2"), actor); }));

  // reference rules
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.scenarios.remove(t, ScenarioId("S"), actor); }));
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.connections.remove(t, ConnectionId("C"), actor); }));
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.workspaces.remove(t, WorkspaceId("W"), actor); }));
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.datasets.remove(t, DatasetId("D"), actor); }), "bound as input");
  assert(failsWith(AilpErrorKind.ruleViolation, () {
      c.ports.configurations.create(createCommand(t, actor, "x", ConfigurationInput("S", "X", "batch", [], [])));
    }), "executable not offered");
  assert(failsWith(AilpErrorKind.invalid, () {
      c.ports.connections.update(updateCommand(t, actor, "C", ConnectionInput("other"), "workspaceId"));
    }), "immutable");

  // changing the endpoint invalidates the connection; the client secret is never returned
  ConnectionInput ci;
  ci.url = "https://api.ai.example.org/v2";
  assert(c.ports.connections.update(updateCommand(t, actor, "C", ci, "url")).status == ConnectionStatus.pending);
  auto row = c.engine.read(RequestContext.local("default", "test"), "Connections", "C");
  assert(row["clientSecret"].type == Json.Type.null_ && row["hasSecret"].get!bool && !row.toString.canFind("secret\""));
}

/// The generative AI hub: templates, versions, the playground.
unittest {
  auto b = newBed();
  auto c = b.c;
  c.ports.workspaces.create(createCommand(t, actor, "W", WorkspaceInput("W", "", "active")));
  c.ports.promptCollections.create(createCommand(t, actor, "pc", PromptCollectionInput("W", "Collection", "")));
  PromptInput p;
  p.collectionId = "pc";
  p.name = "Greet";
  p.systemMessage = "Answer in {{language}}.";
  p.userMessage = "Greet {{name}}";
  auto prompt = c.ports.prompts.create(createCommand(t, actor, "greet", p));
  assert(prompt.inputParams == ["language", "name"] && prompt.version_ == 1);
  assert(failsWith(AilpErrorKind.invalid, () { c.ports.prompts.run(t, PromptId("greet"), ["name": "Ada"], actor); }));
  auto r = c.ports.prompts.run(t, PromptId("greet"), ["name": "Ada", "language": "English"], actor);
  assert(r.renderedPrompt == "Answer in English.\n\nGreet Ada" && r.output.canFind("Greet Ada") && r.promptTokens > 0);
  assert(c.ports.prompts.get(t, PromptId("greet")).runCount == 1);

  p.userMessage = "Hello {{name}}";
  assert(c.ports.prompts.update(updateCommand(t, actor, "greet", p, "userMessage")).version_ == 2);
  p.temperature = 0.1;
  assert(c.ports.prompts.update(updateCommand(t, actor, "greet", p, "temperature")).version_ == 2, "parameters keep the version");
  p.status = "archived";
  c.ports.prompts.update(updateCommand(t, actor, "greet", p, "status"));
  assert(failsWith(AilpErrorKind.ruleViolation, () {
      c.ports.prompts.run(t, PromptId("greet"), ["name": "x", "language": "y"], actor);
    }));
  p.userMessage = "Broken {{a-b}}";
  assert(failsWith(AilpErrorKind.invalid, () { c.ports.prompts.update(updateCommand(t, actor, "greet", p, "userMessage")); }));
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.promptCollections.remove(t, PromptCollectionId("pc"), actor); }));
  // the audit log records the run, not the prompt text
  auto logs = c.ports.auditLog.list(t);
  assert(logs.any!(e => e.eventType == "prompt.run" && e.category == LogCategory.genai));
  assert(!logs.any!(e => e.details.canFind("Ada") || e.message.canFind("Ada")));
}

/// Launchpad tiles: defaults, scope filter, KPI values, validation, restore.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto all = c.ports.tiles.launchpad(t, ["Read", "Operate", "Develop", "Manage", "Admin"], true);
  assert(all.length == defaultTiles.length);
  auto viewer = c.ports.tiles.launchpad(t, ["Read"], true);
  assert(viewer.length < all.length && !viewer.any!(x => x.tile.groupName == "Administration")
      && !viewer.any!(x => x.tile.id.value == "playground"));
  assert(c.ports.tiles.launchpad(t, [], false).length == all.length, "open mode shows everything");
  auto users = all.filter!(x => x.tile.id.value == "users").front;
  assert(users.hasKpi && users.kpiValue == 0);
  // groups appear in the order of their lowest sort order
  assert(all[0].tile.groupName == "AI Runtimes" && all[$ - 1].tile.groupName == "Help");

  TileInput ti;
  ti.title = "Bad";
  ti.target = "Lifecycle";
  assert(failsWith(AilpErrorKind.invalid, () { c.ports.tiles.create(createCommand(t, actor, "bad", ti)); }));
  ti.target = "lifecycle/executions";
  ti.kpi = "nope";
  assert(failsWith(AilpErrorKind.invalid, () { c.ports.tiles.create(createCommand(t, actor, "bad", ti)); }));
  ti.kpi = "executions";
  ti.requiredScope = "operate";
  ti.visible = false;
  auto tile = c.ports.tiles.create(createCommand(t, actor, "mine", ti));
  assert(tile.requiredScope == "Operate", "canonical scope");
  assert(c.ports.tiles.launchpad(t, knownScopes, true).length == all.length, "invisible");
  c.ports.tiles.remove(t, TileId("workspaces"), actor);
  assert(c.ports.tiles.restoreDefaults(t, actor) == defaultTiles.length);
  assert(c.ports.tiles.list(t).length == defaultTiles.length && c.ports.tiles.ensureDefaults(t) == 0);
}

/// Users and roles: scopes from roles, the last administrator, built-in roles.
unittest {
  auto b = newBed();
  auto c = b.c;
  assert(c.ports.roles.list(t).length == 5 && c.ports.roles.ensureBuiltInRoles(t) == 0);
  assert(c.ports.users.ensureAdministrator(t, "admin", "correct horse battery"));
  assert(!c.ports.users.ensureAdministrator(t, "admin2", "correct horse battery"));
  auto admin = UserId("admin");

  CreateUserRequest r;
  r.tenantId = t;
  r.actor = admin;
  r.id = "ada";
  r.password = "ada secret 1";
  r.email = "ada@example.com";
  r.roles = ["Developer"];
  auto ada = c.ports.users.createUser(r);
  assert(c.ports.users.scopesOf(t, ada) == ["Read", "Operate", "Develop"]);
  r.id = "ghost";
  r.roles = ["Nope"];
  assert(failsWith(AilpErrorKind.notFound, () { c.ports.users.createUser(r); }));

  // custom role
  c.ports.roles.create(createCommand(t, admin, "auditor", RoleInput("Auditor", "Reads the audit log", ["Admin"])));
  assert(c.ports.roles.get(t, RoleId("auditor")).scopes == ["Read", "Admin"] && !c.ports.roles.get(t, RoleId("auditor")).builtIn);
  UpdateUserRequest u;
  u.tenantId = t;
  u.actor = admin;
  u.id = "ada";
  u.roles = ["Developer", "auditor"];
  assert(c.ports.users.scopesOf(t, c.ports.users.updateUser(u)) == knownScopes[0 .. 3] ~ ["Admin"]);
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.roles.remove(t, RoleId("auditor"), admin); }), "assigned");
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.roles.remove(t, RoleId("Viewer"), admin); }), "built-in");
  assert(failsWith(AilpErrorKind.ruleViolation, () {
      c.ports.roles.update(updateCommand(t, admin, "Administrator", RoleInput("", "", ["Read"]), "scopes"));
    }));

  // ada is an administrator through "auditor": admin may now be locked; ada may not lose Admin then
  UpdateUserRequest lockAdmin;
  lockAdmin.tenantId = t;
  lockAdmin.actor = UserId("ada");
  lockAdmin.id = "admin";
  lockAdmin.locked = true;
  c.ports.users.updateUser(lockAdmin);
  UpdateUserRequest demote;
  demote.tenantId = t;
  demote.actor = UserId("ada");
  demote.id = "ada";
  demote.roles = ["Developer"];
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.users.updateUser(demote); }), "last administrator");
  assert(failsWith(AilpErrorKind.ruleViolation, () {
      c.ports.roles.update(updateCommand(t, UserId("ada"), "auditor", RoleInput("", "", ["Read"]), "scopes"));
    }), "the role holds the last Admin scope");
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.ports.users.deleteUser(t, UserAccountId("ada"), UserId("ada")); }));
}

/// Built-in login, the persistent audit log and its retention.
unittest {
  auto b = newBed(["authMode": Json("jwt"), "jwtSecret": Json("0123456789abcdef0123456789abcdef"),
      "maxFailedLogins": Json(2)]);
  auto c = b.c;
  c.ports.users.ensureAdministrator(t, "admin", "correct horse battery");
  LoginRequest l;
  l.tenantId = t;
  l.username = "admin";
  l.password = "wrong";
  assert(failsWith(AilpErrorKind.unauthorized, () { c.ports.authentication.login(l); }));
  assert(failsWith(AilpErrorKind.unauthorized, () { c.ports.authentication.login(l); }));
  l.password = "correct horse battery";
  assert(failsWith(AilpErrorKind.unauthorized, () { c.ports.authentication.login(l); }), "temporarily locked");
  b.clock.advance(901);
  auto ok = c.ports.authentication.login(l);
  assert(ok.scopes == knownScopes && ok.token.accessToken.length > 20);

  auto logs = c.ports.auditLog.list(t);
  assert(logs[0].eventType == "login.succeeded", "newest first");
  assert(logs.count!(e => e.eventType == "login.failed" || e.eventType == "login.locked") == 3);
  assert(logs.any!(e => e.eventType == "login.locked" && e.severity == LogSeverity.warning && e.category == LogCategory.security));
  assert(!logs.any!(e => e.details.canFind("correct horse") || e.details.canFind("wrong")), "no passwords in the log");

  auto before = c.ports.auditLog.list(t).length;
  b.clock.advance(31 * 86_400);
  c.ports.authentication.login(l);
  auto purged = c.ports.auditLog.purge(t, UserId("admin"));
  assert(purged.entries == before, purged.entries.to!string ~ " of " ~ before.to!string);
  assert(c.ports.auditLog.list(t).map!(e => e.eventType).array == ["log.purged", "login.succeeded"]);
}

/// REST and OData with the built-in JWT login: tokens, scopes, the launchpad.
unittest {
  auto b = newBed(["authMode": Json("jwt"), "jwtSecret": Json("0123456789abcdef0123456789abcdef")]);
  auto c = b.c;
  c.ports.users.ensureAdministrator(t, "admin", "correct horse battery");
  auto router = routerOf(c);
  int status;

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", "/api/v1/ai-launchpad/launchpad", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/odata/v4/ai-launchpad/$metadata", Json.undefined, status);
  assert(status == 401);
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);

  string login(string user, string password) {
    int s;
    auto r = call(router, "POST", "/auth/login", Json(["username": Json(user), "password": Json(password)]), s);
    assert(s == 200, r.toString);
    return r["access_token"].get!string;
  }

  auto admin = login("admin", "correct horse battery");
  auto created = call(router, "POST", "/api/v1/ai-launchpad/users", Json(["id": Json("bob"), "password": Json("bob secret 1"),
      "roles": Json([Json("Viewer")])]), status, admin);
  assert(status == 201 && created["scopesText"].get!string == "Read" && created["password"].type == Json.Type.null_,
    created.toString);
  auto viewer = login("bob", "bob secret 1");

  auto tiles = call(router, "GET", "/api/v1/ai-launchpad/launchpad", Json.undefined, status, viewer);
  assert(status == 200 && tiles["count"].get!long < defaultTiles.length, tiles.toString);
  auto adminTiles = call(router, "GET", "/api/v1/ai-launchpad/launchpad", Json.undefined, status, admin);
  assert(adminTiles["count"].get!long == defaultTiles.length);

  call(router, "POST", "/api/v1/ai-launchpad/workspaces", Json(["id": Json("W"), "name": Json("W")]), status, viewer);
  assert(status == 403);
  call(router, "GET", "/api/v1/ai-launchpad/users", Json.undefined, status, viewer);
  assert(status == 403);
  call(router, "GET", "/api/v1/ai-launchpad/logs", Json.undefined, status, viewer);
  assert(status == 403);
  auto seed = call(router, "POST", "/api/v1/ai-launchpad/demo-data", Json.emptyObject, status, admin);
  assert(status == 200 && seed["prompts"].get!long == 3, seed.toString);

  auto run = call(router, "POST", "/api/v1/ai-launchpad/prompts/classify-ticket/run",
    Json(["inputs": Json(["ticket": Json("I was charged twice")])]), status, admin);
  assert(status == 200 && run["output"].get!string.canFind("charged twice"), run.toString);
  call(router, "POST", "/api/v1/ai-launchpad/prompts/classify-ticket/run", Json.emptyObject, status, viewer);
  assert(status == 403, "Operate needed");

  auto executions = call(router, "GET", "/api/v1/ai-launchpad/scenarios/fraud-detection/executions", Json.undefined, status, viewer);
  assert(status == 200 && executions["count"].get!long == 1);
  auto exec = executions["resources"][0]["id"].get!string;
  auto stopped = call(router, "POST", "/api/v1/ai-launchpad/executions/" ~ exec ~ "/stop", Json.emptyObject, status, admin);
  assert(status == 200 && stopped["status"].get!string == "stopped");
  call(router, "POST", "/api/v1/ai-launchpad/executions/" ~ exec ~ "/stop", Json.emptyObject, status, admin);
  assert(status == 422);

  auto logs = call(router, "GET", "/api/v1/ai-launchpad/logs?$filter=category%20eq%20'security'&$orderby=createdAt%20desc",
    Json.undefined, status, admin);
  assert(status == 200 && logs["count"].get!long >= 3, logs.toString);
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, viewer);
  assert(status == 200 && me["roles"][0].get!string == "Viewer" && me["scopes"].length == 1, me.toString);

  auto metadata = call(router, "GET", "/odata/v4/ai-launchpad/$metadata", Json.undefined, status, viewer);
  assert(status == 200 && metadata.get!string.canFind("LaunchpadTiles"));
  auto stats = call(router, "GET", "/odata/v4/ai-launchpad/Statistics", Json.undefined, status, viewer);
  assert(status == 200 && stats["users"].get!long == 2, stats.toString);
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("bob secret 1"), "newPassword": Json("bob secret 2")]),
    status, viewer);
  assert(status == 204);
  login("bob", "bob secret 2");
  auto health = call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200 && health["status"].get!string == "UP" && health["runtime"].get!string == "simulate");
}

/// The CLI on top of the same engine.
unittest {
  auto b = newBed();
  string text;
  auto cli = buildAilpCli(b.c, (string s) @safe { text ~= s; });
  assert(cli.run(["seed"]) == 0 && text.canFind("2 workspaces"), text);
  assert(cli.run(["launchpad"]) == 0 && text.canFind("Prompt Management"), text);
  assert(cli.run(["validate", "aicore-eu"]) == 0, text);
  assert(cli.run(["validate", "aicore-legacy"]) == 3, "an invalid connection exits with 3");
  assert(cli.run(["run-prompt", "summarize-ticket", "language=English", "ticket=Printer is on fire"]) == 0
      && text.canFind("Printer is on fire"), text);
  assert(cli.run(["execute", "fraud-train"]) == 0 && text.canFind("pending"), text);
  assert(cli.run(["reconcile"]) == 0 && text.canFind("started"), text);
  assert(cli.run(["logs", "--top=10"]) == 0 && text.canFind("prompt.run"), text);
  assert(cli.run(["stats"]) == 0 && text.canFind("Running Executions"), text);
}

/// The file store: server, CLI and GUI share one snapshot; batches write it once.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;
  import std.uuid : randomUUID;

  auto file = buildPath(tempDir, "uim-ailp-" ~ randomUUID.toString, "data.json");
  scope (exit)
    if (exists(dirName(file)))
      rmdirRecurse(dirName(file));
  auto b = newBed(["storage": Json("file"), "dataFile": Json(file)]);
  seedDemoData(b.c.ports, t, actor);
  auto other = new AilpContainer(loadAilpConfig(["storage": Json("file"), "dataFile": Json(file),
      "passwordIterations": Json(1000)], "/nonexistent"));
  assert(other.ports.prompts.list(t).length == 3 && other.ports.tiles.list(t).length == defaultTiles.length);
}
