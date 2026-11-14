/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.services.statistics;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportStatisticsService : ITransportStatisticsService, ITransportLandscapeService {
  protected ITransportNodeRepository nodes;
  protected ITransportRouteRepository routes;
  protected ITransportRequestRepository requests;
  protected IImportQueueEntryRepository queue;
  protected ITransportActionRepository actions;

  this(ITransportNodeRepository nodes, ITransportRouteRepository routes, ITransportRequestRepository requests,
      IImportQueueEntryRepository queue, ITransportActionRepository actions) {
    this.nodes = nodes;
    this.routes = routes;
    this.requests = requests;
    this.queue = queue;
    this.actions = actions;
  }

  TransportStatistics statistics(TenantId tenantId) {
    TransportStatistics s;
    s.tenantId = tenantId;

    auto allNodes = nodes.findByTenant(tenantId);
    s.nodes = allNodes.length;
    s.enabledNodes = allNodes.count!(n => n.isEnabled);

    auto allRoutes = routes.findByTenant(tenantId);
    s.routes = allRoutes.length;
    s.enabledRoutes = allRoutes.count!(r => r.isEnabled);

    auto allRequests = requests.findByTenant(tenantId);
    s.requests = allRequests.length;
    foreach (st; [EnumMembers!RequestStatus])
      s.requestsByStatus[enumName(st)] = 0;
    foreach (r; allRequests) {
      s.requestsByStatus[enumName(r.status)]++;
      s.requestsByContentType[enumName(r.contentType)] = s.requestsByContentType.get(enumName(r.contentType), 0) + 1;
    }

    auto entries = queue.findByTenant(tenantId);
    s.queueEntries = entries.length;
    s.pendingImports = entries.count!(e => e.isPending);
    s.runningImports = entries.count!(e => e.status == ImportStatus.running);
    s.failedImports = entries.count!(e => e.status == ImportStatus.failed);
    s.successfulImports = entries.count!(e => e.status == ImportStatus.success || e.status == ImportStatus.warning);

    auto trail = actions.findByTenant(tenantId);
    s.actions = trail.length;
    foreach (a; trail)
      s.lastActionAt = max(s.lastActionAt, a.performedAt);
    return s;
  }

  TransportLandscape landscape(TenantId tenantId) {
    return TransportLandscape(nodes.findByTenant(tenantId), routes.findByTenant(tenantId));
  }
}
