/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.persistence.memory.transport_routes;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

class MemoryTransportRouteRepository : TenantRepository!(TransportRoute, TransportRouteId), TransportRouteRepository {

    TransportRoute[] findBySourceNode(TenantId tenantId, TransportNodeId sourceNodeId) {
        return find(tenantId).filter!(e => e.sourceNodeId.value == sourceNodeId.value).array;
    }

    TransportRoute[] findByDestinationNode(TenantId tenantId, TransportNodeId destNodeId) {
        return find(tenantId).filter!(e => e.destinationNodeId.value == destNodeId.value).array;
    }

    TransportRoute[] findByStatus(TenantId tenantId, RouteStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }
}
