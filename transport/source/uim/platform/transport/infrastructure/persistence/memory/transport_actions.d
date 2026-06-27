/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.persistence.memory.transport_actions;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

class MemoryTransportActionRepository : TentRepository!(TransportAction, TransportActionId), TransportActionRepository {

    TransportAction[] findByNode(TenantId tenantId, TransportNodeId nodeId) {
        return findByTenant(tenantId).filter!(e => e.nodeId.value == nodeId.value).array;
    }

    TransportAction[] findByRequest(TenantId tenantId, TransportRequestId requestId) {
        return findByTenant(tenantId).filter!(e => e.requestId.value == requestId.value).array;
    }

    TransportAction[] findByType(TenantId tenantId, ActionType actionType) {
        return findByTenant(tenantId).filter!(e => e.actionType == actionType).array;
    }

    TransportAction[] findByStatus(TenantId tenantId, ActionStatus actionStatus) {
        return findByTenant(tenantId).filter!(e => e.actionStatus == actionStatus).array;
    }
}
