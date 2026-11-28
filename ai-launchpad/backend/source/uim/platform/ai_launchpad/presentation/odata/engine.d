/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST API, the CLI and the GUI.
module uim.platform.ai_launchpad.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates AiLaunchpadException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

/// A provider over a maintained resource port; rows(t, entities) builds the
/// rows of many entities at once (derived facts are computed once per call).
PortProvider resourceProvider(TEntity, TId, TInput, R)(IManageResource!(TEntity, TId, TInput) port, R rows) {
  auto p = new DelegateEntitySetProvider;
  p.onList = (const RequestContext ctx) => rows(tenantOf(ctx), port.list(tenantOf(ctx)));
  p.onGet = (const RequestContext ctx, string key) => rows(tenantOf(ctx), [port.get(tenantOf(ctx), TId(key))])[0];
  p.onCreate = (const RequestContext ctx, Json payload) => rows(tenantOf(ctx), [
    port.create(createCommandOf!TInput(ctx, payload))
  ])[0];
  p.onUpdate = (const RequestContext ctx, string key, Json payload) => rows(tenantOf(ctx), [
    port.update(updateCommandOf!TInput(ctx, key, payload))
  ])[0];
  p.onRemove = (const RequestContext ctx, string key) { port.remove(tenantOf(ctx), TId(key), actorOf(ctx)); };
  return new PortProvider(p);
}

ODataEngine launchpadEngine(AilpPorts ports, IClock clock, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(launchpadModel());

  // ── lookups ─────────────────────────────────────────────────────────────
  string[string] namesOf(R)(R items) {
    string[string] n;
    foreach (x; items)
      n[x.id.value] = x.name;
    return n;
  }

  long[string] countBy(alias key, R)(R items) {
    long[string] n;
    foreach (x; items)
      n[key(x)]++;
    return n;
  }

  // ── row builders with derived facts ─────────────────────────────────────
  Json[] workspaceRows(TenantId t, Workspace[] items) {
    auto connections = countBy!(c => c.workspaceId.value)(ports.connections.list(t));
    auto collections = countBy!(c => c.workspaceId.value)(ports.promptCollections.list(t));
    return items.map!(w => workspaceRow(w, connections.get(w.id.value, 0), collections.get(w.id.value, 0))).array;
  }

  Json[] connectionRows(TenantId t, Connection[] items) {
    auto workspaces = namesOf(ports.workspaces.list(t));
    auto groups = countBy!(g => g.connectionId.value)(ports.resourceGroups.list(t));
    auto scenarios = countBy!(s => s.connectionId.value)(ports.scenarios.list(t));
    return items.map!(c => connectionRow(c, workspaces.get(c.workspaceId.value, ""), groups.get(c.id.value, 0),
        scenarios.get(c.id.value, 0))).array;
  }

  Json[] resourceGroupRows(TenantId t, ResourceGroup[] items) {
    auto connections = namesOf(ports.connections.list(t));
    long[string] executions, deployments;
    foreach (e; ports.executions.list(t))
      if (e.isActive)
        executions[e.resourceGroupId.value]++;
    foreach (d; ports.deployments.list(t))
      if (d.isActive)
        deployments[d.resourceGroupId.value]++;
    return items.map!(g => resourceGroupRow(g, connections.get(g.connectionId.value, ""), executions.get(g.id.value, 0),
        deployments.get(g.id.value, 0))).array;
  }

  Json[] scenarioRows(TenantId t, Scenario[] items) {
    auto connections = namesOf(ports.connections.list(t));
    auto configurations = countBy!(c => c.scenarioId.value)(ports.configurations.list(t));
    auto executions = countBy!(e => e.scenarioId.value)(ports.executions.list(t));
    auto deployments = countBy!(d => d.scenarioId.value)(ports.deployments.list(t));
    auto models = countBy!(m => m.scenarioId.value)(ports.models.list(t));
    auto datasets = countBy!(d => d.scenarioId.value)(ports.datasets.list(t));
    return items.map!((s) {
      auto k = s.id.value;
      return scenarioRow(s, connections.get(s.connectionId.value, ""), UsageCounts(configurations.get(k, 0),
        executions.get(k, 0), deployments.get(k, 0), models.get(k, 0), datasets.get(k, 0)));
    }).array;
  }

  Json[] configurationRows(TenantId t, Configuration[] items) {
    auto scenarios = namesOf(ports.scenarios.list(t));
    auto executions = countBy!(e => e.configurationId.value)(ports.executions.list(t));
    auto deployments = countBy!(d => d.configurationId.value)(ports.deployments.list(t));
    return items.map!((c) {
      UsageCounts n;
      n.executions = executions.get(c.id.value, 0);
      n.deployments = deployments.get(c.id.value, 0);
      return configurationRow(c, scenarios.get(c.scenarioId.value, ""), n);
    }).array;
  }

  Json[] executionRows(TenantId t, Execution[] items) {
    auto configurations = namesOf(ports.configurations.list(t));
    auto scenarios = namesOf(ports.scenarios.list(t));
    return items.map!(e => executionRow(e, configurations.get(e.configurationId.value, ""),
        scenarios.get(e.scenarioId.value, ""))).array;
  }

  Json[] deploymentRows(TenantId t, Deployment[] items) {
    auto configurations = namesOf(ports.configurations.list(t));
    auto scenarios = namesOf(ports.scenarios.list(t));
    return items.map!(d => deploymentRow(d, configurations.get(d.configurationId.value, ""),
        scenarios.get(d.scenarioId.value, ""))).array;
  }

  Json[] modelRows(TenantId t, Model[] items) {
    auto scenarios = namesOf(ports.scenarios.list(t));
    return items.map!(m => modelRow(m, scenarios.get(m.scenarioId.value, ""))).array;
  }

  Json[] datasetRows(TenantId t, Dataset[] items) {
    auto scenarios = namesOf(ports.scenarios.list(t));
    return items.map!(d => datasetRow(d, scenarios.get(d.scenarioId.value, ""))).array;
  }

  Json[] promptCollectionRows(TenantId t, PromptCollection[] items) {
    auto workspaces = namesOf(ports.workspaces.list(t));
    auto prompts = countBy!(p => p.collectionId.value)(ports.prompts.list(t));
    return items.map!(c => promptCollectionRow(c, workspaces.get(c.workspaceId.value, ""), prompts.get(c.id.value, 0)))
      .array;
  }

  Json[] promptRows(TenantId t, Prompt[] items) {
    auto collections = namesOf(ports.promptCollections.list(t));
    return items.map!(p => promptRow(p, collections.get(p.collectionId.value, ""))).array;
  }

  Json[] tileRows(TenantId t, Tile[] items) {
    return items.map!(x => tileRow(x)).array;
  }

  Json[] roleRows(TenantId t, Role[] items) {
    long[string] users;
    foreach (u; ports.users.listUsers(t))
      foreach (r; u.roles)
        users[r]++;
    return items.map!(r => roleRow(r, users.get(r.id.value, 0))).array;
  }

  Json userRowOf(TenantId t, UserAccount u) {
    return userRow(u, ports.users.scopesOf(t, u), clock.now);
  }

  // ── entity sets ─────────────────────────────────────────────────────────
  engine.provide("Workspaces", resourceProvider(
      cast(IManageResource!(Workspace, WorkspaceId, WorkspaceInput)) ports.workspaces, &workspaceRows));
  engine.provide("Connections", resourceProvider(
      cast(IManageResource!(Connection, ConnectionId, ConnectionInput)) ports.connections, &connectionRows));
  engine.provide("ResourceGroups", resourceProvider(
      cast(IManageResource!(ResourceGroup, ResourceGroupId, ResourceGroupInput)) ports.resourceGroups, &resourceGroupRows));
  engine.provide("Scenarios", resourceProvider(
      cast(IManageResource!(Scenario, ScenarioId, ScenarioInput)) ports.scenarios, &scenarioRows));
  engine.provide("Configurations", resourceProvider(
      cast(IManageResource!(Configuration, ConfigurationId, ConfigurationInput)) ports.configurations, &configurationRows));
  engine.provide("Executions", resourceProvider(
      cast(IManageResource!(Execution, ExecutionId, ExecutionInput)) ports.executions, &executionRows));
  engine.provide("Deployments", resourceProvider(
      cast(IManageResource!(Deployment, DeploymentId, DeploymentInput)) ports.deployments, &deploymentRows));
  engine.provide("Models", resourceProvider(cast(IManageResource!(Model, ModelId, ModelInput)) ports.models, &modelRows));
  engine.provide("Datasets", resourceProvider(
      cast(IManageResource!(Dataset, DatasetId, DatasetInput)) ports.datasets, &datasetRows));
  engine.provide("PromptCollections", resourceProvider(
      cast(IManageResource!(PromptCollection, PromptCollectionId, PromptCollectionInput)) ports.promptCollections,
      &promptCollectionRows));
  engine.provide("Prompts", resourceProvider(cast(IManageResource!(Prompt, PromptId, PromptInput)) ports.prompts, &promptRows));
  engine.provide("Tiles", resourceProvider(cast(IManageResource!(Tile, TileId, TileInput)) ports.tiles, &tileRows));
  engine.provide("Roles", resourceProvider(cast(IManageResource!(Role, RoleId, RoleInput)) ports.roles, &roleRows));

  // the tiles of the caller (scope filtered when the server enforces scopes)
  auto launchpad = new DelegateEntitySetProvider;
  launchpad.onList = (const RequestContext ctx) => ports.tiles.launchpad(tenantOf(ctx), ctx.scopes, engine.enforceScopes)
    .map!(x => launchpadTileRow(x)).array;
  launchpad.onGet = (const RequestContext ctx, string key) {
    foreach (x; ports.tiles.launchpad(tenantOf(ctx), ctx.scopes, engine.enforceScopes))
      if (x.tile.id.value == key)
        return launchpadTileRow(x);
    throw AilpException.notFound("Tile '" ~ key ~ "'");
  };
  engine.provide("LaunchpadTiles", new PortProvider(launchpad));

  auto users = new DelegateEntitySetProvider;
  users.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    return ports.users.listUsers(t).map!(u => userRowOf(t, u)).array;
  };
  users.onGet = (const RequestContext ctx, string key) => userRowOf(tenantOf(ctx), ports.users.getUser(tenantOf(ctx),
      UserAccountId(key)));
  users.onCreate = (const RequestContext ctx, Json p) => userRowOf(tenantOf(ctx), ports.users.createUser(
      createUserRequest(ctx, p)));
  users.onUpdate = (const RequestContext ctx, string key, Json p) => userRowOf(tenantOf(ctx),
    ports.users.updateUser(updateUserRequest(ctx, key, p)));
  users.onRemove = (const RequestContext ctx, string key) {
    ports.users.deleteUser(tenantOf(ctx), UserAccountId(key), actorOf(ctx));
  };
  engine.provide("Users", new PortProvider(users));

  auto logs = new DelegateEntitySetProvider;
  logs.onList = (const RequestContext ctx) => ports.auditLog.list(tenantOf(ctx)).map!(e => logEntryRow(e)).array;
  logs.onGet = (const RequestContext ctx, string key) => logEntryRow(ports.auditLog.get(tenantOf(ctx), LogEntryId(key)));
  engine.provide("LogEntries", new PortProvider(logs));

  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));
  engine.provide("Statistics", new PortProvider(statistics));

  // ── actions ─────────────────────────────────────────────────────────────
  void action(string name, Json delegate(const RequestContext, Json) @safe handler) {
    engine.handle(name, (const RequestContext ctx, Json p) => translated!Json(() => handler(ctx, p)));
  }

  Json one(alias rows, E)(const RequestContext ctx, E e) {
    return rows(tenantOf(ctx), [e])[0];
  }

  action("ValidateConnection", (ctx, p) => one!connectionRows(ctx, ports.connections.validateConnection(tenantOf(ctx),
      ConnectionId(idParam(p)), actorOf(ctx))));
  action("StopExecution", (ctx, p) => one!executionRows(ctx, ports.executions.stop(tenantOf(ctx), ExecutionId(idParam(p)),
      actorOf(ctx))));
  action("StopDeployment", (ctx, p) => one!deploymentRows(ctx, ports.deployments.stop(tenantOf(ctx),
      DeploymentId(idParam(p)), actorOf(ctx))));
  action("StartDeployment", (ctx, p) => one!deploymentRows(ctx, ports.deployments.start(tenantOf(ctx),
      DeploymentId(idParam(p)), actorOf(ctx))));
  action("RunPrompt", (ctx, p) => promptRunRow(ports.prompts.run(tenantOf(ctx), PromptId(idParam(p)), inputsParam(p),
      actorOf(ctx))));
  action("Reconcile", (ctx, p) => reconcileRow(ports.reconciler.reconcile(tenantOf(ctx), actorOf(ctx))));
  action("PurgeLogs", (ctx, p) => purgeRow(ports.auditLog.purge(tenantOf(ctx), actorOf(ctx))));
  action("RestoreDefaultTiles", (ctx, p) => Json(["tiles": Json(ports.tiles.restoreDefaults(tenantOf(ctx), actorOf(ctx)))]));
  action("SeedDemoData", (ctx, p) => seedRow(seedDemoData(ports, tenantOf(ctx), actorOf(ctx))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
