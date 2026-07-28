/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.persistence.repositories.transport_requests;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class MemoryTransportRequestRepository : TenantRepository!(TransportRequest, TransportRequestId), TransportRequestRepository {

    TransportRequest[] findByStatus(TenantId tenantId, RequestStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    TransportRequest[] findBySourceNode(TenantId tenantId, TransportNodeId nodeId) {
        return findByTenant(tenantId).filter!(e => e.sourceNodeId.value == nodeId.value).array;
    }

    TransportRequest[] findByContentType(TenantId tenantId, ContentType contentType) {
        return findByTenant(tenantId).filter!(e => e.contentType == contentType).array;
    }
}
