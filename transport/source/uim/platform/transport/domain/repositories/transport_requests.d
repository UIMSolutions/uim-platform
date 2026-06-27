/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.repositories.transport_requests;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

interface TransportRequestRepository : ITenantRepository!(TransportRequest, TransportRequestId) {
    TransportRequest[] findByStatus(TenantId tenantId, RequestStatus status);
    TransportRequest[] findBySourceNode(TenantId tenantId, TransportNodeId nodeId);
    TransportRequest[] findByContentType(TenantId tenantId, ContentType contentType);
}
