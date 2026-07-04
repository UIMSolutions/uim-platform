/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.repositories.transport_routes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

interface TransportRouteRepository : ITenantRepository!(TransportRoute, TransportRouteId) {
    TransportRoute[] findBySourceNode(TenantId tenantId, TransportNodeId sourceNodeId);
    TransportRoute[] findByDestinationNode(TenantId tenantId, TransportNodeId destNodeId);
    TransportRoute[] findByStatus(TenantId tenantId, RouteStatus status);
}
