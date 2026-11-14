/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.repositories.transport_requests;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of transport requests.
interface ITransportRequestRepository : ITenantRepository!(TransportRequest, TransportRequestId) {
  TransportRequest[] findByStatus(TenantId tenantId, RequestStatus status);
  TransportRequest[] findBySourceNode(TenantId tenantId, TransportNodeId nodeId);
  TransportRequest[] findByContentType(TenantId tenantId, ContentType contentType);
}
