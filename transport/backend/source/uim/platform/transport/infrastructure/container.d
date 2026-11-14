/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.container;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Dependency injection container (composition root of the application core).
/// It wires persistence, gateways and use cases; the presentation adapters
/// (REST, OData, CLI, GUI) are created by the entry points (app.d, cli.d, gui.d)
/// on top of `ports` and never see a concrete class.
class Container {
  TransportConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  TransportNodeRepository nodeRepo;
  TransportRouteRepository routeRepo;
  TransportRequestRepository requestRepo;
  ImportQueueEntryRepository queueRepo;
  TransportActionRepository actionRepo;
  IDeploymentGateway gateway;
  ITransportEventPublisher publisher;

  // ── Application ──────────────────────────────────────────────────────
  TransportActionRecorder recorder;
  IManageTransportNodesUseCase manageNodes;
  IManageTransportRoutesUseCase manageRoutes;
  IManageTransportRequestsUseCase manageRequests;
  IManageImportQueueUseCase manageQueue;
  IManageTransportActionsUseCase manageActions;
  ITransportOperationsUseCase operations;
  TransportStatisticsService statistics;

  this(TransportConfig config, IDeploymentGateway gateway = null, ITransportEventPublisher publisher = null) {
    this.config = config;
    this.gateway = gateway !is null ? gateway : new SimulatedDeploymentGateway();
    this.publisher = publisher !is null ? publisher : new LogEventPublisher();
    wirePersistence();
    wireApplication();
  }

  /// The driving ports for presentation adapters.
  TransportPorts ports() {
    TransportPorts p;
    p.nodes = manageNodes;
    p.routes = manageRoutes;
    p.requests = manageRequests;
    p.queue = manageQueue;
    p.actions = manageActions;
    p.operations = operations;
    p.statistics = statistics;
    p.landscape = statistics;
    return p;
  }

  protected void wirePersistence() {
    if (config.usesFileStorage) {
      storage = new JsonFileSnapshotStorage(config.dataDir);
      nodeRepo = new TransportNodeRepository(
        new SnapshotTenantStore!(TransportNode, TransportNodeId, TransportNodeMapper)(storage, TransportCollections.nodes));
      routeRepo = new TransportRouteRepository(
        new SnapshotTenantStore!(TransportRoute, TransportRouteId, TransportRouteMapper)(storage, TransportCollections.routes));
      requestRepo = new TransportRequestRepository(
        new SnapshotTenantStore!(TransportRequest, TransportRequestId, TransportRequestMapper)(storage, TransportCollections.requests));
      queueRepo = new ImportQueueEntryRepository(
        new SnapshotTenantStore!(ImportQueueEntry, ImportQueueEntryId, ImportQueueEntryMapper)(storage, TransportCollections.queueEntries));
      actionRepo = new TransportActionRepository(
        new SnapshotTenantStore!(TransportAction, TransportActionId, TransportActionMapper)(storage, TransportCollections.actions));
    } else {
      nodeRepo = new TransportNodeRepository();
      routeRepo = new TransportRouteRepository();
      requestRepo = new TransportRequestRepository();
      queueRepo = new ImportQueueEntryRepository();
      actionRepo = new TransportActionRepository();
    }
  }

  protected void wireApplication() {
    recorder = new TransportActionRecorder(actionRepo);
    manageNodes = new ManageTransportNodesUseCase(nodeRepo, routeRepo, queueRepo);
    manageRoutes = new ManageTransportRoutesUseCase(routeRepo, nodeRepo);
    manageRequests = new ManageTransportRequestsUseCase(requestRepo, nodeRepo, queueRepo, recorder, publisher);
    manageQueue = new ManageImportQueueUseCase(queueRepo, nodeRepo, requestRepo, recorder, publisher);
    manageActions = new ManageTransportActionsUseCase(actionRepo);
    operations = new TransportOperationsUseCase(nodeRepo, routeRepo, requestRepo, queueRepo, recorder, gateway, publisher);
    statistics = new TransportStatisticsService(nodeRepo, routeRepo, requestRepo, queueRepo, actionRepo);
  }
}

/// Build the full dependency graph.
Container buildContainer(TransportConfig config) {
  return new Container(config);
}

/// End-to-end test of the transport workflow DEV → QA → PROD.
unittest {
  mixin(ShowTest!("Container / transport workflow"));

  TransportConfig cfg;
  cfg.storage = "memory";
  auto events = new MemoryEventPublisher();
  auto c = new Container(cfg, null, events);
  auto p = c.ports;
  auto t = TenantId("t1");

  string node(string name) {
    CreateNodeInput n;
    n.tenantId = t;
    n.name = name;
    auto r = p.nodes.createNode(n);
    assert(r.isSuccess, r.message);
    return r.id;
  }

  auto dev = node("DEV"), qa = node("QA"), prod = node("PROD");
  assert(!p.nodes.createNode(CreateNodeInput(t, "", "DEV")).isSuccess); // duplicate name

  string route(string name, string from, string to) {
    CreateRouteInput r;
    r.tenantId = t;
    r.name = name;
    r.sourceNodeId = from;
    r.destinationNodeId = to;
    return p.routes.createRoute(r).id;
  }

  assert(route("dev-qa", dev, qa).length > 0);
  assert(route("qa-prod", qa, prod).length > 0);
  CreateRouteInput cyc = {tenantId: t, name: "prod-dev", sourceNodeId: prod, destinationNodeId: dev};
  assert(p.routes.createRoute(cyc).code == 422); // cycle rejected

  CreateRequestInput rq = {tenantId: t, name: "my-app", sourceNodeId: dev, storageUrl: "https://store/my-app.mtar"};
  auto requestId = TransportRequestId(p.requests.createRequest(rq).id);

  // export DEV → queue of QA
  ExportInput ex = {tenantId: t, requestId: requestId, performedBy: "jane"};
  assert(p.operations.exportRequest(ex).isSuccess);
  assert(p.queue.listEntriesByNode(t, TransportNodeId(qa)).length == 1);
  assert(p.requests.getRequest(t, requestId).status == RequestStatus.initial);

  // import QA → success + forwarded to PROD
  ImportInput im = {tenantId: t, nodeId: TransportNodeId(qa), performedBy: "jane"};
  auto run = p.operations.importNode(im);
  assert(run.isSuccess && run.data["succeeded"].get!long == 1 && run.data["forwarded"].get!long == 1, run.message);
  assert(p.queue.listEntriesByNode(t, TransportNodeId(prod)).length == 1);
  assert(p.requests.getRequest(t, requestId).status == RequestStatus.running); // still queued in PROD

  // import PROD → request completely successful
  im.nodeId = TransportNodeId(prod);
  assert(p.operations.importNode(im).data["succeeded"].get!long == 1);
  assert(p.requests.getRequest(t, requestId).status == RequestStatus.success);

  // reset + re-import
  auto prodEntry = p.queue.listEntriesByNode(t, TransportNodeId(prod))[0];
  assert(p.queue.resetEntry(t, prodEntry.id, "jane").isSuccess);
  assert(p.requests.getRequest(t, requestId).status == RequestStatus.repeating);

  auto stats = p.statistics.statistics(t);
  assert(stats.nodes == 3 && stats.routes == 2 && stats.requests == 1 && stats.pendingImports == 1);
  assert(p.actions.listActions(t).length >= 5); // export, import, forward, import, reset
  assert(events.topics.canFind(cast(string) TransportTopics.importFinished));

  // nodes with routes cannot be deleted
  assert(p.nodes.deleteNode(t, TransportNodeId(qa)).code == 422);
  assert(p.landscape.landscape(t).render.canFind("DEV"));
}
