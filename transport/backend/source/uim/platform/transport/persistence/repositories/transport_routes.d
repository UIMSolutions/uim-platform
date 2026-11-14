/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.repositories.transport_routes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportRouteRepository : TenantRepository!(TransportRoute, TransportRouteId), ITransportRouteRepository {
  this() {
    super();
  }

  this(ITenantStore!(TransportRoute, TransportRouteId) store) {
    super(store);
  }

  TransportRoute[] findBySourceNode(TenantId tenantId, TransportNodeId sourceNodeId) {
    return findByTenant(tenantId).filter!(e => e.sourceNodeId == sourceNodeId).array;
  }

  TransportRoute[] findByDestinationNode(TenantId tenantId, TransportNodeId destNodeId) {
    return findByTenant(tenantId).filter!(e => e.destinationNodeId == destNodeId).array;
  }

  TransportRoute[] findByNode(TenantId tenantId, TransportNodeId nodeId) {
    return findByTenant(tenantId).filter!(e => e.touches(nodeId)).array;
  }

  TransportRoute[] findByStatus(TenantId tenantId, RouteStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }
}

///
unittest {
  mixin(ShowTest!("TransportRouteRepository"));

  auto repo = new TransportRouteRepository();
  auto e = TransportRoute(TenantId("t1"));
  repo.save(e);
  assert(repo.existsById(TenantId("t1"), e.id));
  assert(repo.countByTenant(TenantId("t1")) == 1);
  repo.remove(e);
  assert(repo.countByTenant(TenantId("t1")) == 0);
}
