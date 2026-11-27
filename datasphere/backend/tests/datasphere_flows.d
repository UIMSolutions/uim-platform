/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the demo content, the
/// data flow through the ports (connection → remote table → view → data
/// flow → task → task chain → runs), quotas and locked spaces, schedules
/// and the scheduler, row level security, the business rules of every
/// resource, the REST API and the OData endpoint over vibe.d test
/// requests, the built-in JWT login with scopes, the CLI and the batching
/// file store.
module tests.datasphere_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.datasphere;

@safe:

version (unittest) {
  /// 2026-11-25T10:00:00Z
  long t0() {
    return parseIsoTime("2026-11-25T10:00:00Z");
  }

  struct TestBed {
    DspContainer c;
    ManualClock clock;
  }

  TestBed newBed(Json[string] extra = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["schedulerIntervalSeconds"] = 0;
    o["passwordIterations"] = 1000;
    foreach (k, v; extra)
      o[k] = v;
    TestBed b;
    b.clock = new ManualClock(t0);
    b.c = new DspContainer(loadDspConfig(o, "/nonexistent"), storage, b.clock);
    b.c.audit.log = false;
    return b;
  }

  /// One HTTP call through the router; text bodies are sent as is.
  Json call(URLRouter router, string method, string path, Json body, out int status, string bearer = "", string text = "") @trusted {
    InetHeaderMap headers;
    headers["Content-Type"] = "application/json";
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

  URLRouter routerOf(DspContainer c) {
    c.engine.enforceScopes = c.security.requireAuthentication; // as in app.d
    auto router = new URLRouter;
    new DspHealthController(c.config, c.security.mode, c.processing.mode, c.metrics).registerRoutes(router, c.config.apiPath);
    new AuthController(c.ports, c.security).registerRoutes(router);
    new DspApiController(c.engine, c.ports, c.security, c.config.policy, "/api/v1", "2.0.0", 4 * 1024 * 1024,
      capabilitiesJson(c.processing.mode, c.config.policy)).registerRoutes(router);
    auto odata = new ODataController(c.engine, "/odata/v4/datasphere");
    odata.verifier = c.security.verifier;
    odata.requireAuthentication = c.security.requireAuthentication;
    odata.registerRoutes(router);
    return router;
  }

  auto t = TenantId("default");
  auto actor = UserId("tester");

  /// A minimal space S with a valid HANA connection H and a remote table T (columns A, B).
  void miniSpace(DspContainer c, double diskGiB = 10) {
    SpaceInput s;
    s.name = "Space S";
    s.diskQuotaGiB = diskGiB;
    s.memoryQuotaGiB = 0.25;
    c.ports.spaces.create(createCommand(t, actor, "S", s));
    ConnectionInput h;
    h.spaceId = "S";
    h.name = "HANA";
    h.host = "hana.example.com";
    h.port = 443;
    h.user = "u";
    h.password = "p";
    c.ports.connections.create(createCommand(t, actor, "H", h));
    RemoteTableInput r;
    r.spaceId = "S";
    r.connectionId = "H";
    r.name = "T";
    r.remoteObject = "TABLE_T";
    r.columns = ["A:NVARCHAR(10) key", "B:DECIMAL(15,2)"];
    c.ports.remoteTables.create(createCommand(t, actor, "t", r));
  }

  TaskRun[] runsOf(DspContainer c) {
    return c.ports.monitor.listRuns(t);
  }
}

/// The demo content: validated connections, a completed nightly chain, a failed replication.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto r = seedDemoData(c.ports, t, actor);
  assert(r.spaces == 2 && r.connections == 3 && r.remoteTables == 4 && r.views == 2 && r.tasks == 5 && r.taskChains == 1);
  assert(failsWith(DspErrorKind.ruleViolation, () { seedDemoData(c.ports, t, actor); }), "only once");

  assert(c.ports.connections.get(t, ConnectionId("S4")).isValid);
  auto legacy = c.ports.connections.get(t, ConnectionId("LEGACY"));
  assert(legacy.status == ConnectionStatus.invalid && legacy.statusMessage.canFind("not reachable"), legacy.statusMessage);

  auto chain = c.ports.taskChains.get(t, TaskChainId("nightly"));
  assert(chain.lastRunStatus == RunStatus.completed, chain.lastRunMessage);
  assert(chain.lastRunMessage == "4 of 4 steps completed" && chain.nextRunAt > t0, chain.lastRunMessage);
  auto orders = c.ports.remoteTables.get(t, RemoteTableId("orders"));
  assert(orders.replicationStatus == ReplicationStatus.replicated && orders.rowCount >= 1000 && orders.sizeBytes > 0);
  auto flow = c.ports.dataFlows.get(t, DataFlowId("orders-dach"));
  assert(flow.lastRunStatus == RunStatus.completed && flow.targetRows == cast(long)(orders.rowCount * 0.4), flow.lastRunMessage);
  auto view = c.ports.views.get(t, DataViewId("sales-orders"));
  assert(view.persisted && view.rowCount > orders.rowCount, "orders + customers"); // sources of the persisted view

  // the legacy task: two attempts (one retry), both failed
  auto task = c.ports.tasks.get(t, TaskId("replicate-legacy"));
  assert(task.lastRunStatus == RunStatus.failed && task.consecutiveFailures == 1 && task.lastRunMessage.canFind("invalid"));
  auto legacyRuns = runsOf(c).filter!(x => x.taskId == "replicate-legacy").array;
  assert(legacyRuns.length == 2 && legacyRuns[1].attempts == 2);
  // runs: 1 chain + 4 steps + 2 legacy attempts
  assert(r.runs == 7 && runsOf(c).count!(x => x.chainRunId.length) == 4, r.runs.to!string);

  // the space usage follows the objects
  auto space = c.ports.spaces.get(t, SpaceId("SALES"));
  assert(space.usedDiskBytes == orders.sizeBytes + c.ports.remoteTables.get(t, RemoteTableId("customers")).sizeBytes
      + view.persistedBytes + flow.targetBytes);
  auto stats = c.ports.statistics.compute(t);
  assert(stats.spaces == 2 && stats.validConnections == 2 && stats.replicatedTables == 2 && stats.deployedViews == 2);
  assert(stats.runsLast24h == 3 && stats.failedRunsLast24h == 2 && stats.scheduledTasks == 1, stats.to!string);
}

/// Modeling rules: SQL, sources, deployment status, references.
unittest {
  auto b = newBed();
  auto c = b.c;
  miniSpace(c);

  ViewInput v;
  v.spaceId = "S";
  v.name = "V";
  v.sqlExpression = "SELECT A, B FROM T WHERE B > 0";
  v.columns = ["A:NVARCHAR(10) key", "B:DECIMAL(15,2)"];
  auto view = c.ports.views.create(createCommand(t, actor, "v", v));
  assert(view.sourceObjects == ["T"] && view.deploymentStatus == DeploymentStatus.notDeployed);
  view = c.ports.views.deploy(t, DataViewId("v"), actor);
  assert(view.isDeployed);
  // a change of the SQL needs a new deployment
  ViewInput changes;
  changes.sqlExpression = "SELECT A FROM T";
  view = c.ports.views.update(updateCommand(t, actor, "v", changes, "sqlExpression"));
  assert(view.deploymentStatus == DeploymentStatus.changesToDeploy);
  // a description change does not
  c.ports.views.deploy(t, DataViewId("v"), actor);
  changes.description = "doc";
  assert(c.ports.views.update(updateCommand(t, actor, "v", changes, "description")).deploymentStatus == DeploymentStatus.deployed);
  // immutable name, unique names, DML and unknown sources
  changes.name = "W";
  assert(failsWith(DspErrorKind.invalid, () { c.ports.views.update(updateCommand(t, actor, "v", changes, "name")); }));
  v.name = "t";
  assert(failsWith(DspErrorKind.conflict, () { c.ports.views.create(createCommand(t, actor, "", v)); }), "T exists (case insensitive)");
  v.name = "V2";
  v.sqlExpression = "DELETE FROM T";
  assert(failsWith(DspErrorKind.invalid, () { c.ports.views.create(createCommand(t, actor, "", v)); }));
  v.sqlExpression = "SELECT * FROM NOPE";
  c.ports.views.create(createCommand(t, actor, "v2", v));
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.views.deploy(t, DataViewId("v2"), actor); }));
  // a view must not be persisted before it is deployed (a failed run, not an exception)
  auto run = c.ports.views.persist(t, DataViewId("v2"), actor);
  assert(run.status == RunStatus.failed && run.message.canFind("not deployed"));

  // data flows: deploy needs sources and a target; the target is a new object of the space
  DataFlowInput f;
  f.spaceId = "S";
  f.name = "F";
  f.sourceObjects = ["T"];
  c.ports.dataFlows.create(createCommand(t, actor, "f", f));
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.dataFlows.deploy(t, DataFlowId("f"), actor); }));
  DataFlowInput target;
  target.targetTable = "V";
  assert(failsWith(DspErrorKind.conflict, () {
      c.ports.dataFlows.update(updateCommand(t, actor, "f", target, "targetTable"));
    }), "name of the view");
  target.targetTable = "T_OUT";
  target.transforms = ["filter: B > 100", "aggregation: SUM(B) BY A"];
  c.ports.dataFlows.update(updateCommand(t, actor, "f", target, "targetTable", "transforms"));
  c.ports.dataFlows.deploy(t, DataFlowId("f"), actor);

  // references: remote table T is used by the views and the data flow
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.remoteTables.remove(t, RemoteTableId("t"), actor); }));
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.connections.remove(t, ConnectionId("H"), actor); }));
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.spaces.remove(t, SpaceId("S"), actor); }));
}

/// Runs: replication with automatic connection check, data flow, persistence, quota, locked space.
unittest {
  auto b = newBed();
  auto c = b.c;
  miniSpace(c, 0.25);

  auto run = c.ports.remoteTables.replicate(t, RemoteTableId("t"), actor);
  assert(run.succeeded && run.rowsProcessed >= 1000 && run.objectName == "T", run.message);
  assert(c.ports.connections.get(t, ConnectionId("H")).isValid, "validated on first use");
  auto table = c.ports.remoteTables.get(t, RemoteTableId("t"));
  assert(table.replicationMode == ReplicationMode.snapshot && table.rowCount == run.rowsProcessed);
  assert(table.sizeBytes == run.rowsProcessed * 36, table.sizeBytes.to!string); // 20 + 16 bytes per row
  auto space = c.ports.spaces.get(t, SpaceId("S"));
  assert(space.usedDiskBytes == table.sizeBytes);

  // switching back to federation drops the replica and frees the disk
  RemoteTableInput i;
  i.replicationMode = "remote";
  c.ports.remoteTables.update(updateCommand(t, actor, "t", i, "replicationMode"));
  assert(c.ports.spaces.get(t, SpaceId("S")).usedDiskBytes == 0);

  // a tiny quota fails the replication
  SpaceInput q;
  q.diskQuotaGiB = 0.25;
  q.memoryQuotaGiB = 0.25;
  c.ports.spaces.update(updateCommand(t, actor, "S", q, "diskQuotaGiB", "memoryQuotaGiB"));
  auto remote = c.ports.remoteTables.get(t, RemoteTableId("t"));
  remote.columns = ["A:NVARCHAR(5000) key"]; // 10 000 bytes per row
  c.repositories.remoteTables.save(remote);
  run = c.ports.remoteTables.replicate(t, RemoteTableId("t"), actor);
  assert(!run.succeeded && run.message.canFind("disk quota"), run.message);

  // a locked space refuses runs and new objects
  c.ports.spaces.lock(t, SpaceId("S"), "maintenance", actor);
  run = c.ports.remoteTables.replicate(t, RemoteTableId("t"), actor);
  assert(!run.succeeded && run.message.canFind("locked") && run.message.canFind("maintenance"), run.message);
  ConnectionInput h;
  h.spaceId = "S";
  h.name = "x";
  h.connectionType = "file";
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.connections.create(createCommand(t, actor, "", h)); }));
  c.ports.spaces.unlock(t, SpaceId("S"), actor);

  // changing the credentials resets the connection status
  ConnectionInput pw;
  pw.password = "new";
  assert(c.ports.connections.update(updateCommand(t, actor, "H", pw, "password")).status == ConnectionStatus.untested);
  pw.password = ""; // keeps the stored password
  c.ports.connections.validateConnection(t, ConnectionId("H"), actor);
  assert(c.ports.connections.update(updateCommand(t, actor, "H", pw, "password")).password == "new");

  // real-time replication needs a capable connection type
  ConnectionInput odata;
  odata.spaceId = "S";
  odata.name = "OData";
  odata.connectionType = "odata";
  odata.host = "svc.example.com";
  odata.port = 443;
  c.ports.connections.create(createCommand(t, actor, "O", odata));
  RemoteTableInput rt;
  rt.spaceId = "S";
  rt.connectionId = "O";
  rt.name = "OT";
  rt.remoteObject = "Orders";
  rt.replicationMode = "realtime";
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.remoteTables.create(createCommand(t, actor, "", rt)); }));
}

/// Tasks, retries, chains (stop / continue) and the scheduler.
unittest {
  auto b = newBed();
  auto c = b.c;
  miniSpace(c);
  RemoteTableInput bad;
  bad.spaceId = "S";
  bad.connectionId = "H";
  bad.name = "GONE";
  bad.remoteObject = "MISSING_OBJECT";
  c.ports.remoteTables.create(createCommand(t, actor, "gone", bad));

  TaskInput good;
  good.spaceId = "S";
  good.name = "Replicate T";
  good.targetObjectId = "t";
  good.frequency = "interval";
  good.intervalMinutes = 30;
  auto task = c.ports.tasks.create(createCommand(t, actor, "rt", good));
  assert(task.isScheduled && isoTimeText(task.nextRunAt) == "2026-11-25T10:30:00Z", isoTimeText(task.nextRunAt));
  TaskInput failing = good;
  failing.name = "Replicate missing";
  failing.targetObjectId = "gone";
  failing.frequency = "manual";
  failing.maxRetries = 2;
  c.ports.tasks.create(createCommand(t, actor, "rg", failing));
  TaskInput wrong = good;
  wrong.taskType = "dataFlow";
  assert(failsWith(DspErrorKind.notFound, () { c.ports.tasks.create(createCommand(t, actor, "", wrong)); }));
  wrong.taskType = "replication";
  wrong.intervalMinutes = 1;
  assert(failsWith(DspErrorKind.invalid, () { c.ports.tasks.create(createCommand(t, actor, "", wrong)); }));

  // retries: 3 attempts, all failed
  auto run = c.ports.tasks.runTask(t, TaskId("rg"), actor);
  assert(!run.succeeded && run.attempts == 3 && run.message.canFind("does not exist"), run.message);
  assert(runsOf(c).count!(x => x.taskId == "rg") == 3);

  // chains: stop cancels the later steps, continue runs them
  TaskChainInput chain;
  chain.spaceId = "S";
  chain.name = "Chain";
  chain.taskIds = ["rg", "rt"];
  c.ports.taskChains.create(createCommand(t, actor, "c", chain));
  auto chainRun = c.ports.taskChains.runChain(t, TaskChainId("c"), actor);
  assert(!chainRun.succeeded && chainRun.message.canFind("1 cancelled"), chainRun.message);
  auto steps = runsOf(c).filter!(x => x.chainRunId == chainRun.id.value).array;
  assert(steps.length == 4 && steps[$ - 1].status == RunStatus.cancelled, steps.length.to!string); // 3 attempts + cancelled
  TaskChainInput policy;
  policy.failurePolicy = "continue";
  c.ports.taskChains.update(updateCommand(t, actor, "c", policy, "failurePolicy"));
  chainRun = c.ports.taskChains.runChain(t, TaskChainId("c"), actor);
  assert(!chainRun.succeeded && chainRun.message.canFind("1 of 2 steps failed, 0 cancelled"), chainRun.message);
  assert(c.ports.tasks.get(t, TaskId("rt")).lastRunStatus == RunStatus.completed);
  // a task in a chain cannot be deleted; a chain of another space is refused
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.tasks.remove(t, TaskId("rt"), actor); }));

  // the scheduler: nothing due at t0, the interval task after 30 minutes
  auto s = c.ports.monitor.runDue(t, actor);
  assert(s.due == 0, s.summary);
  b.clock.advance(31 * 60);
  s = c.ports.monitor.runDue(t, actor);
  assert(s.due == 1 && s.completed == 1, s.summary);
  task = c.ports.tasks.get(t, TaskId("rt"));
  assert(isoTimeText(task.nextRunAt) == "2026-11-25T11:00:00Z" && task.lastRunStatus == RunStatus.completed,
    isoTimeText(task.nextRunAt));
  // paused schedules do not fire; a locked space skips and replans
  c.ports.tasks.pause(t, TaskId("rt"), actor);
  b.clock.advance(60 * 60);
  assert(c.ports.monitor.runDue(t, actor).due == 0);
  c.ports.tasks.resume(t, TaskId("rt"), actor);
  b.clock.advance(31 * 60);
  c.ports.spaces.lock(t, SpaceId("S"), "", actor);
  s = c.ports.monitor.runDue(t, actor);
  assert(s.due == 1 && s.skipped == 1 && s.started == 0, s.summary);
  assert(c.ports.tasks.get(t, TaskId("rt")).nextRunAt > b.clock.now);
  c.ports.spaces.unlock(t, SpaceId("S"), actor);

  // retention: old finished runs are purged
  auto before = runsOf(c).length;
  b.clock.advance(31 * 86_400);
  assert(c.ports.monitor.purgeRuns(t, actor).runs == before && runsOf(c).length == 0);

  // the worker never throws and counts its runs
  auto worker = new SchedulerWorker(c.ports, ["default", "other"], 2, c.metrics);
  auto total = worker.runOnce();
  assert(c.metrics.runs == 1 && total.due == 1 && c.metrics.completed == 1, total.summary);
}

/// Row level security and governance.
unittest {
  auto b = newBed();
  auto c = b.c;
  seedDemoData(c.ports, t, actor);
  auto row = Json(["COUNTRY": Json("DE"), "NETAMOUNT": Json(10)]);
  assert(c.ports.views.checkAccess(t, DataViewId("sales-orders"), "ada", row).allowed);
  auto denied = c.ports.views.checkAccess(t, DataViewId("sales-orders"), "bob", row);
  assert(!denied.allowed && denied.protected_ && denied.reason.canFind("none"), denied.reason);
  assert(!c.ports.views.checkAccess(t, DataViewId("sales-orders"), "ada", Json(["COUNTRY": Json("US")])).allowed);
  assert(c.ports.views.checkAccess(t, DataViewId("customers-dim"), "bob", row).allowed, "unprotected");
  // a protected view cannot be deleted; controls only protect views of their space
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.views.remove(t, DataViewId("sales-orders"), actor); }));
  AccessControlInput other;
  other.spaceId = "HR";
  other.name = "x";
  other.criteriaColumn = "C";
  other.criteriaValues = ["1"];
  other.targetViewIds = ["sales-orders"];
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.accessControls.create(createCommand(t, actor, "", other)); }));

  // catalog: search ranks by name, tags and description; the source must exist
  auto hits = c.ports.catalog.search(t, "sales", SpaceId(""));
  assert(hits.length == 2 && hits[0].id.value == "asset-sales-orders", hits.map!(h => h.id.value).join(","));
  assert(c.ports.catalog.search(t, "industry", SpaceId("SALES"))[0].id.value == "asset-customers");
  assert(c.ports.catalog.search(t, "sales", SpaceId("HR")).length == 0);
  assert(c.ports.catalog.recordAccess(t, CatalogAssetId("asset-customers")).accessCount == 1);
  CatalogAssetInput asset;
  asset.spaceId = "SALES";
  asset.name = "x";
  asset.sourceObjectId = "nope";
  assert(failsWith(DspErrorKind.notFound, () { c.ports.catalog.create(createCommand(t, actor, "", asset)); }));

  // members: one membership per user, the last administrator stays
  MemberInput m;
  m.spaceId = "SALES";
  m.userName = "ada";
  assert(failsWith(DspErrorKind.conflict, () { c.ports.members.create(createCommand(t, actor, "", m)); }));
  assert(failsWith(DspErrorKind.ruleViolation, () { c.ports.members.remove(t, SpaceMemberId("HR.admin"), actor); }));
  MemberInput demote;
  demote.role = "viewer";
  assert(failsWith(DspErrorKind.ruleViolation, () {
      c.ports.members.update(updateCommand(t, actor, "HR.admin", demote, "role"));
    }));
  // an empty space can be deleted (with its members)
  c.ports.spaces.remove(t, SpaceId("HR"), actor);
  assert(c.ports.members.list(t).count!(x => x.spaceId.value == "HR") == 0);
  // the quota cannot drop below the used disk
  SpaceInput q;
  q.diskQuotaGiB = 0.25;
  q.memoryQuotaGiB = 0.25;
  auto used = c.ports.spaces.get(t, SpaceId("SALES")).usedDiskBytes;
  if (used > minQuotaBytes)
    assert(failsWith(DspErrorKind.ruleViolation, () {
        c.ports.spaces.update(updateCommand(t, actor, "SALES", q, "diskQuotaGiB", "memoryQuotaGiB"));
      }));
}

/// REST API and OData endpoint.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto router = routerOf(c);
  int status;

  auto health = call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200 && health["status"].get!string == "UP" && health["processingEngine"].get!string == "simulate");
  call(router, "POST", "/api/v1/datasphere/demo-data", Json.emptyObject, status);
  assert(status == 200, status.to!string);

  auto spaces = call(router, "GET", "/api/v1/datasphere/spaces?$orderby=id", Json.undefined, status);
  assert(status == 200 && spaces["count"].get!long == 2 && spaces["resources"][1]["objectCount"].get!long > 10, spaces.toString);
  auto views = call(router, "GET", "/api/v1/datasphere/spaces/SALES/views", Json.undefined, status);
  assert(status == 200 && views["count"].get!long == 2, views.toString);
  call(router, "GET", "/api/v1/datasphere/spaces/NOPE/views", Json.undefined, status);
  assert(status == 404);
  auto conn = call(router, "GET", "/api/v1/datasphere/connections/S4", Json.undefined, status);
  assert(status == 200 && conn["password"].type == Json.Type.null_ && conn["hasPassword"].get!bool, conn.toString);
  assert(!conn.toString.canFind("demo-secret"));

  // create, PATCH, conflicts, immutables, read-only sets
  auto created = call(router, "POST", "/api/v1/datasphere/remote-tables", Json(["id": Json("gl2"), "spaceId": Json("SALES"),
      "connectionId": Json("HANA"), "name": Json("FIN_GL2"), "remoteObject": Json("GL"),
      "columns": Json([Json("ACCOUNT:NVARCHAR(10) key"), Json("AMOUNT:DECIMAL(15,2)")])]), status);
  assert(status == 201 && created["columnCount"].get!long == 2 && created["connectionName"].get!string.canFind("HANA"),
    created.toString);
  call(router, "POST", "/api/v1/datasphere/remote-tables", Json(["id": Json("gl2"), "spaceId": Json("SALES"),
      "connectionId": Json("HANA"), "name": Json("X"), "remoteObject": Json("GL")]), status);
  assert(status == 409);
  auto patched = call(router, "PATCH", "/api/v1/datasphere/remote-tables/gl2", Json(["businessName": Json("G/L 2")]), status);
  assert(status == 200 && patched["businessName"].get!string == "G/L 2");
  call(router, "PATCH", "/api/v1/datasphere/remote-tables/gl2", Json(["connectionId": Json("S4")]), status);
  assert(status == 400 || status == 200, status.to!string); // immutable: ignored by the engine or refused
  call(router, "POST", "/api/v1/datasphere/runs", Json(["objectId": Json("x")]), status);
  assert(status == 405 || status == 400 || status == 501, status.to!string);
  call(router, "DELETE", "/api/v1/datasphere/connections/S4", Json.undefined, status);
  assert(status == 422, "used by remote tables");

  // operations
  auto run = call(router, "POST", "/api/v1/datasphere/remote-tables/gl2/replicate", Json.emptyObject, status);
  assert(status == 200 && run["status"].get!string == "completed" && run["objectType"].get!string == "replication",
    run.toString);
  auto task = call(router, "POST", "/api/v1/datasphere/tasks/replicate-legacy/run", Json.emptyObject, status);
  assert(status == 200 && task["status"].get!string == "failed", task.toString);
  auto history = call(router, "GET", "/api/v1/datasphere/tasks/replicate-legacy/runs", Json.undefined, status);
  assert(status == 200 && history["count"].get!long == 4, history.toString);
  auto chainRuns = call(router, "GET", "/api/v1/datasphere/task-chains/nightly/runs", Json.undefined, status);
  assert(status == 200 && chainRuns["count"].get!long == 1);
  auto steps = call(router, "GET", "/api/v1/datasphere/runs/" ~ chainRuns["resources"][0]["id"].get!string ~ "/steps",
    Json.undefined, status);
  assert(status == 200 && steps["count"].get!long == 4, steps.toString);
  auto access = call(router, "POST", "/api/v1/datasphere/views/sales-orders/check-access", Json(["user": Json("bob"),
      "row": Json(["COUNTRY": Json("DE")])]), status);
  assert(status == 200 && !access["allowed"].get!bool && access["protected"].get!bool, access.toString);
  auto locked = call(router, "POST", "/api/v1/datasphere/spaces/HR/lock", Json(["reason": Json("audit")]), status);
  assert(status == 200 && locked["status"].get!string == "locked" && locked["lockedReason"].get!string == "audit");
  auto search = call(router, "GET", "/api/v1/datasphere/catalog/search?q=revenue", Json.undefined, status);
  assert(status == 200 && search["count"].get!long == 1, search.toString);
  call(router, "POST", "/api/v1/datasphere/views/sales-orders/deploy", Json.emptyObject, status);
  assert(status == 200);
  call(router, "POST", "/api/v1/datasphere/scheduler/run", Json.emptyObject, status);
  assert(status == 200);

  // OData
  auto meta = call(router, "GET", "/odata/v4/datasphere/$metadata", Json.undefined, status);
  assert(status == 200 && meta.get!string.canFind(`EntityType Name="RemoteTable"`));
  auto failed = call(router, "GET", "/odata/v4/datasphere/Runs?$filter=status eq 'failed'&$count=true", Json.undefined, status);
  assert(status == 200 && failed["@odata.count"].get!long == 4, failed.toString);
  auto stats = call(router, "GET", "/odata/v4/datasphere/Statistics('default')", Json.undefined, status);
  assert(status == 200 && stats["spaces"].get!long == 2 && stats["lockedSpaces"].get!long == 1, stats.toString);
  auto validated = call(router, "POST", "/odata/v4/datasphere/ValidateConnection", Json(["id": Json("LEGACY")]), status);
  assert(status == 200 && validated["status"].get!string == "invalid", validated.toString);
  auto decision = call(router, "POST", "/odata/v4/datasphere/CheckDataAccess", Json(["viewId": Json("sales-orders"),
      "user": Json("ada"), "row": Json(`{"COUNTRY":"AT"}`)]), status);
  assert(status == 200 && decision["allowed"].get!bool && decision["matchedControls"].get!string == "dach", decision.toString);
  auto caps = call(router, "GET", "/api/v1/datasphere/capabilities", Json.undefined, status);
  assert(status == 200 && caps["processingEngine"].get!string == "simulate");
}

/// Built-in login (authMode jwt): tokens and the scopes Read / Integrate / Model / Manage / Admin.
unittest {
  Json[string] o;
  o["authMode"] = "jwt";
  o["jwtSecret"] = "0123456789abcdef0123456789abcdef-test";
  auto b = newBed(o);
  auto c = b.c;
  assert(c.security.mode == "jwt" && c.security.requireAuthentication);
  assert(c.ports.users.ensureAdministrator(t, "admin", "correct horse battery"));
  assert(!c.ports.users.ensureAdministrator(t, "admin", "correct horse battery"));
  auto router = routerOf(c);
  int status;

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", "/api/v1/datasphere/spaces", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/odata/v4/datasphere/Spaces", Json.undefined, status);
  assert(status == 401);
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);

  string login(string user, string password) {
    int s;
    auto r = call(router, "POST", "/auth/login", Json(["username": Json(user), "password": Json(password)]), s);
    assert(s == 200, r.toString);
    return r["access_token"].get!string;
  }

  void user(string admin, string id, string scope_) {
    int s;
    call(router, "POST", "/api/v1/datasphere/users", Json(["id": Json(id), "password": Json(id ~ " secret 1"),
        "scopes": Json([Json(scope_)])]), s, admin);
    assert(s == 201, s.to!string);
  }

  auto admin = login("admin", "correct horse battery");
  call(router, "POST", "/api/v1/datasphere/demo-data", Json.emptyObject, status, admin);
  assert(status == 200);
  user(admin, "grace", "Integrate");
  user(admin, "ada", "Model");
  user(admin, "bob", "Read");
  auto integrator = login("grace", "grace secret 1");
  auto modeler = login("ada", "ada secret 1");
  auto viewer = login("bob", "bob secret 1");

  // Integrate: runs, but no modeling or space administration
  call(router, "POST", "/api/v1/datasphere/tasks/replicate-orders/run", Json.emptyObject, status, integrator);
  assert(status == 200, status.to!string);
  call(router, "PATCH", "/api/v1/datasphere/views/sales-orders", Json(["description": Json("x")]), status, integrator);
  assert(status == 403);
  // Model: views, but no connections or spaces
  call(router, "PATCH", "/api/v1/datasphere/views/sales-orders", Json(["description": Json("x")]), status, modeler);
  assert(status == 200);
  call(router, "POST", "/api/v1/datasphere/views/sales-orders/deploy", Json.emptyObject, status, modeler);
  assert(status == 200, "Model implies Integrate");
  call(router, "PATCH", "/api/v1/datasphere/connections/S4", Json(["description": Json("x")]), status, modeler);
  assert(status == 403);
  call(router, "POST", "/api/v1/datasphere/spaces/SALES/lock", Json.emptyObject, status, modeler);
  assert(status == 403);
  // Read: reads and access checks only
  call(router, "GET", "/api/v1/datasphere/runs", Json.undefined, status, viewer);
  assert(status == 200);
  call(router, "POST", "/api/v1/datasphere/views/sales-orders/check-access", Json(["row": Json(["COUNTRY": Json("DE")])]),
    status, viewer);
  assert(status == 200);
  call(router, "POST", "/api/v1/datasphere/tasks/replicate-orders/run", Json.emptyObject, status, viewer);
  assert(status == 403);
  call(router, "GET", "/api/v1/datasphere/users", Json.undefined, status, viewer);
  assert(status == 403);
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, modeler);
  assert(status == 200 && me["user"].get!string == "ada" && me["scopes"].length == 3, me.toString);
  // the password of the own account
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("bob secret 1"),
      "newPassword": Json("bob secret 2")]), status, viewer);
  assert(status == 204);
  login("bob", "bob secret 2");
  // the last administrator stays
  call(router, "DELETE", "/api/v1/datasphere/users/admin", Json.undefined, status, admin);
  assert(status == 422);
}

/// The command line adapter.
unittest {
  auto b = newBed();
  auto c = b.c;
  string text;
  auto cli = buildDspCli(c, (string s) @safe { text ~= s; });
  assert(cli.run(["seed"]) == 0, text);
  assert(text.canFind("2 spaces"), text);
  assert(cli.run(["spaces"]) == 0 && text.canFind("Sales Analytics"), text);
  assert(cli.run(["run", "nightly"]) == 0 && text.canFind("completed"), text);
  assert(cli.run(["run", "replicate-legacy"]) == 3, "a failed run exits with 3");
  assert(cli.run(["replicate", "customers"]) == 0, text);
  assert(cli.run(["deploy", "orders-dach"]) == 0 && text.canFind("data flow 'DF_ORDERS_DACH': deployed"), text);
  assert(cli.run(["validate", "LEGACY"]) == 3 && text.canFind("invalid"), text);
  assert(cli.run(["check-access", "sales-orders", "ada", `{"COUNTRY":"CH"}`]) == 0 && text.canFind("allowed"), text);
  assert(cli.run(["search", "customer"]) == 0 && text.canFind("asset-customers"), text);
  assert(cli.run(["pause", "nightly"]) == 0 && text.canFind("paused"), text);
  assert(cli.run(["runs", "SALES", "--status=failed"]) == 0 && text.canFind("LEGACY_ORDERS"), text);
  assert(cli.run(["stats"]) == 0 && text.canFind("Spaces"), text);
  assert(cli.run(["list", "Views", "--filter=exposed eq true"]) == 0, text);
  assert(cli.run(["run", "nope"]) != 0);
}

/// Batching file store: a chain run writes the snapshot once; a second
/// container (the CLI next to the server) sees the data.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;
  import std.uuid : randomUUID;

  auto file = buildPath(tempDir, "uim-dsp-flow-" ~ randomUUID.toString, "data.json");
  scope (exit)
    if (exists(dirName(file)))
      rmdirRecurse(dirName(file));
  auto store = new BatchingFileDocumentStore(file);
  auto b = newBed(null, StorageSetup(store, store));
  seedDemoData(b.c.ports, t, actor);
  auto before = store.flushes;
  b.c.ports.monitor.runDue(t, actor); // nothing due: no write
  assert(store.flushes == before);
  b.clock.advance(2 * 86_400);
  auto s = b.c.ports.monitor.runDue(t, actor);
  assert(s.due == 2 && store.flushes == before + 1, format("%s flushes %d → %d", s.summary, before, store.flushes));

  Json[string] o;
  o["storage"] = "file";
  o["dataFile"] = file;
  auto other = new DspContainer(loadDspConfig(o, "/nonexistent"));
  other.audit.log = false;
  assert(other.ports.views.list(t).length == 2 && other.ports.monitor.listRuns(t).length == b.c.ports.monitor.listRuns(t).length);
}
