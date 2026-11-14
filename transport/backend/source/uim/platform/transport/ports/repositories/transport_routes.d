/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.repositories.transport_routes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of transport routes.
interface ITransportRouteRepository : ITenantRepository!(TransportRoute, TransportRouteId) {
  TransportRoute[] findBySourceNode(TenantId tenantId, TransportNodeId sourceNodeId);
  TransportRoute[] findByDestinationNode(TenantId tenantId, TransportNodeId destNodeId);
  TransportRoute[] findByNode(TenantId tenantId, TransportNodeId nodeId);
  TransportRoute[] findByStatus(TenantId tenantId, RouteStatus status);
}
