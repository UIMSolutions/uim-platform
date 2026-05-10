/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.persistence.memory.transport_nodes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class MemoryTransportNodeRepository : TenantRepository!(TransportNode, TransportNodeId), TransportNodeRepository {

    size_t countByStatus(TenantId tenantId, NodeStatus status) {
        return findByStatus(tenantId, status).length;
    }

    TransportNode[] findByStatus(TenantId tenantId, NodeStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    TransportNode[] findByType(TenantId tenantId, NodeType nodeType) {
        return findByTenant(tenantId).filter!(e => e.nodeType == nodeType).array;
    }
}
