/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.repositories.transport_actions;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

interface TransportActionRepository : ITentRepository!(TransportAction, TransportActionId) {
    TransportAction[] findByNode(TenantId tenantId, TransportNodeId nodeId);
    TransportAction[] findByRequest(TenantId tenantId, TransportRequestId requestId);
    TransportAction[] findByType(TenantId tenantId, ActionType actionType);
    TransportAction[] findByStatus(TenantId tenantId, ActionStatus actionStatus);
}
