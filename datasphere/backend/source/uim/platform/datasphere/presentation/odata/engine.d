/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST API, the CLI and the GUI.
module uim.platform.datasphere.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates DatasphereException.
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

ODataEngine datasphereEngine(DspPorts ports, IClock clock, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(datasphereModel());

  // ── lookups ─────────────────────────────────────────────────────────────
  string[string] namesOf(R)(R items) {
    string[string] n;
    foreach (x; items)
      n[x.id.value] = x.name;
    return n;
  }

  string[string] spaceNames(TenantId t) {
    return namesOf(ports.spaces.list(t));
  }

  // ── row builders with derived facts ─────────────────────────────────────
  Json[] spaceRows(TenantId t, Space[] spaces) {
    long[string] members, objects;
    foreach (m; ports.members.list(t))
      members[m.spaceId.value]++;
    void count(R)(R items) {
      foreach (x; items)
        objects[x.spaceId.value]++;
    }

    count(ports.connections.list(t));
    count(ports.remoteTables.list(t));
    count(ports.views.list(t));
    count(ports.dataFlows.list(t));
    count(ports.tasks.list(t));
    count(ports.taskChains.list(t));
    count(ports.accessControls.list(t));
    count(ports.catalog.list(t));
    return spaces.map!(s => spaceRow(s, members.get(s.id.value, 0), objects.get(s.id.value, 0))).array;
  }

  Json[] memberRows(TenantId t, SpaceMember[] members) {
    auto spaces = spaceNames(t);
    return members.map!(m => memberRow(m, spaces.get(m.spaceId.value, ""))).array;
  }

  Json[] connectionRows(TenantId t, Connection[] connections) {
    auto spaces = spaceNames(t);
    long[string] tables;
    foreach (x; ports.remoteTables.list(t))
      tables[x.connectionId.value]++;
    return connections.map!(c => connectionRow(c, spaces.get(c.spaceId.value, ""), tables.get(c.id.value, 0))).array;
  }

  Json[] remoteTableRows(TenantId t, RemoteTable[] tables) {
    auto spaces = spaceNames(t);
    auto connections = namesOf(ports.connections.list(t));
    return tables.map!(x => remoteTableRow(x, spaces.get(x.spaceId.value, ""), connections.get(x.connectionId.value, "")))
      .array;
  }

  Json[] viewRows(TenantId t, DataView[] views) {
    auto spaces = spaceNames(t);
    long[string] protectedBy;
    foreach (d; ports.accessControls.list(t))
      if (d.enabled)
        foreach (v; d.targetViewIds)
          protectedBy[v]++;
    return views.map!(v => viewRow(v, spaces.get(v.spaceId.value, ""), protectedBy.get(v.id.value, 0))).array;
  }

  Json[] dataFlowRows(TenantId t, DataFlow[] flows) {
    auto spaces = spaceNames(t);
    return flows.map!(f => dataFlowRow(f, spaces.get(f.spaceId.value, ""))).array;
  }

  Json[] taskRows(TenantId t, DataTask[] tasks) {
    auto spaces = spaceNames(t);
    string[string] targets;
    foreach (x; ports.remoteTables.list(t))
      targets["replication/" ~ x.id.value] = x.businessName;
    foreach (x; ports.dataFlows.list(t))
      targets["dataFlow/" ~ x.id.value] = x.businessName;
    foreach (x; ports.views.list(t))
      targets["viewPersistence/" ~ x.id.value] = x.businessName;
    return tasks.map!(x => taskRow(x, spaces.get(x.spaceId.value, ""),
        targets.get(cast(string) x.taskType ~ "/" ~ x.targetObjectId, ""))).array;
  }

  Json[] taskChainRows(TenantId t, TaskChain[] chains) {
    auto spaces = spaceNames(t);
    auto tasks = namesOf(ports.tasks.list(t));
    return chains.map!(c => taskChainRow(c, spaces.get(c.spaceId.value, ""), tasks)).array;
  }

  Json[] runRows(TenantId t, TaskRun[] runs) {
    auto spaces = spaceNames(t);
    return runs.map!(r => runRow(r, spaces.get(r.spaceId.value, ""))).array;
  }

  Json[] accessControlRows(TenantId t, DataAccessControl[] controls) {
    auto spaces = spaceNames(t);
    auto views = namesOf(ports.views.list(t));
    return controls.map!(d => accessControlRow(d, spaces.get(d.spaceId.value, ""), views)).array;
  }

  Json[] catalogRows(TenantId t, CatalogAsset[] assets) {
    auto spaces = spaceNames(t);
    return assets.map!(a => catalogRow(a, spaces.get(a.spaceId.value, ""))).array;
  }

  // ── entity sets ─────────────────────────────────────────────────────────
  engine.provide("Spaces", resourceProvider(cast(IManageResource!(Space, SpaceId, SpaceInput)) ports.spaces, &spaceRows));
  engine.provide("Members", resourceProvider(
      cast(IManageResource!(SpaceMember, SpaceMemberId, MemberInput)) ports.members, &memberRows));
  engine.provide("Connections", resourceProvider(
      cast(IManageResource!(Connection, ConnectionId, ConnectionInput)) ports.connections, &connectionRows));
  engine.provide("RemoteTables", resourceProvider(
      cast(IManageResource!(RemoteTable, RemoteTableId, RemoteTableInput)) ports.remoteTables, &remoteTableRows));
  engine.provide("Views", resourceProvider(cast(IManageResource!(DataView, DataViewId, ViewInput)) ports.views, &viewRows));
  engine.provide("DataFlows", resourceProvider(
      cast(IManageResource!(DataFlow, DataFlowId, DataFlowInput)) ports.dataFlows, &dataFlowRows));
  engine.provide("Tasks", resourceProvider(cast(IManageResource!(DataTask, TaskId, TaskInput)) ports.tasks, &taskRows));
  engine.provide("TaskChains", resourceProvider(
      cast(IManageResource!(TaskChain, TaskChainId, TaskChainInput)) ports.taskChains, &taskChainRows));
  engine.provide("AccessControls", resourceProvider(
      cast(IManageResource!(DataAccessControl, DataAccessControlId, AccessControlInput)) ports.accessControls,
      &accessControlRows));
  engine.provide("CatalogAssets", resourceProvider(
      cast(IManageResource!(CatalogAsset, CatalogAssetId, CatalogAssetInput)) ports.catalog, &catalogRows));

  auto runs = new DelegateEntitySetProvider;
  runs.onList = (const RequestContext ctx) => runRows(tenantOf(ctx), ports.monitor.listRuns(tenantOf(ctx)));
  runs.onGet = (const RequestContext ctx, string key) => runRows(tenantOf(ctx), [
    ports.monitor.getRun(tenantOf(ctx), TaskRunId(key))
  ])[0];
  engine.provide("Runs", new PortProvider(runs));

  auto users = new DelegateEntitySetProvider;
  users.onList = (const RequestContext ctx) {
    auto at = clock.now;
    return ports.users.listUsers(tenantOf(ctx)).map!(u => userRow(u, at)).array;
  };
  users.onGet = (const RequestContext ctx, string key) => userRow(ports.users.getUser(tenantOf(ctx), UserAccountId(key)), clock.now);
  users.onCreate = (const RequestContext ctx, Json p) => userRow(ports.users.createUser(createUserRequest(ctx, p)), clock.now);
  users.onUpdate = (const RequestContext ctx, string key, Json p) => userRow(
    ports.users.updateUser(updateUserRequest(ctx, key, p)), clock.now);
  users.onRemove = (const RequestContext ctx, string key) {
    ports.users.deleteUser(tenantOf(ctx), UserAccountId(key), actorOf(ctx));
  };
  engine.provide("Users", new PortProvider(users));

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

  action("LockSpace", (ctx, p) => one!spaceRows(ctx, ports.spaces.lock(tenantOf(ctx), SpaceId(idParam(p)),
      textOf(p, "reason"), actorOf(ctx))));
  action("UnlockSpace", (ctx, p) => one!spaceRows(ctx, ports.spaces.unlock(tenantOf(ctx), SpaceId(idParam(p)), actorOf(ctx))));
  action("ValidateConnection", (ctx, p) => one!connectionRows(ctx, ports.connections.validateConnection(tenantOf(ctx),
      ConnectionId(idParam(p)), actorOf(ctx))));
  action("ReplicateRemoteTable", (ctx, p) => one!runRows(ctx, ports.remoteTables.replicate(tenantOf(ctx),
      RemoteTableId(idParam(p)), actorOf(ctx))));
  action("DropReplica", (ctx, p) => one!remoteTableRows(ctx, ports.remoteTables.dropReplica(tenantOf(ctx),
      RemoteTableId(idParam(p)), actorOf(ctx))));
  action("DeployView", (ctx, p) => one!viewRows(ctx, ports.views.deploy(tenantOf(ctx), DataViewId(idParam(p)), actorOf(ctx))));
  action("PersistView", (ctx, p) => one!runRows(ctx, ports.views.persist(tenantOf(ctx), DataViewId(idParam(p)), actorOf(ctx))));
  action("RemovePersistence", (ctx, p) => one!viewRows(ctx, ports.views.removePersistence(tenantOf(ctx),
      DataViewId(idParam(p)), actorOf(ctx))));
  action("CheckDataAccess", (ctx, p) {
    auto view = idParam(p, "viewId");
    auto user = idParam(p, "user");
    return accessDecisionRow(ports.views.checkAccess(tenantOf(ctx), DataViewId(view), user, jsonParam(p, "row")), view, user);
  });
  action("DeployDataFlow", (ctx, p) => one!dataFlowRows(ctx, ports.dataFlows.deploy(tenantOf(ctx), DataFlowId(idParam(p)),
      actorOf(ctx))));
  action("RunDataFlow", (ctx, p) => one!runRows(ctx, ports.dataFlows.run(tenantOf(ctx), DataFlowId(idParam(p)), actorOf(ctx))));
  action("RunTask", (ctx, p) => one!runRows(ctx, ports.tasks.runTask(tenantOf(ctx), TaskId(idParam(p)), actorOf(ctx))));
  action("PauseTask", (ctx, p) => one!taskRows(ctx, ports.tasks.pause(tenantOf(ctx), TaskId(idParam(p)), actorOf(ctx))));
  action("ResumeTask", (ctx, p) => one!taskRows(ctx, ports.tasks.resume(tenantOf(ctx), TaskId(idParam(p)), actorOf(ctx))));
  action("RunTaskChain", (ctx, p) => one!runRows(ctx, ports.taskChains.runChain(tenantOf(ctx), TaskChainId(idParam(p)),
      actorOf(ctx))));
  action("PauseTaskChain", (ctx, p) => one!taskChainRows(ctx, ports.taskChains.pause(tenantOf(ctx), TaskChainId(idParam(p)),
      actorOf(ctx))));
  action("ResumeTaskChain", (ctx, p) => one!taskChainRows(ctx, ports.taskChains.resume(tenantOf(ctx),
      TaskChainId(idParam(p)), actorOf(ctx))));
  action("RunDueSchedules", (ctx, p) => schedulerRow(ports.monitor.runDue(tenantOf(ctx), actorOf(ctx))));
  action("PurgeRuns", (ctx, p) => purgeRow(ports.monitor.purgeRuns(tenantOf(ctx), actorOf(ctx))));
  action("SeedDemoData", (ctx, p) => seedRow(seedDemoData(ports, tenantOf(ctx), actorOf(ctx))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
