/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.usecases.transport_requests;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Application service for transport request lifecycle management.
interface IManageTransportRequestsUseCase { 
  
  UsecaseResult createTransportRequest(CreateTransportRequest req);
  UsecaseResult releaseTransport(ReleaseTransportRequest req);
  UsecaseResult cancelTransport(TenantId tenantId, TransportRequestId requestId);
  TransportRequest getTransportRequest(TenantId tenantId, TransportRequestId id);
  TransportRequest[] listTransportRequests(TenantId tenantId);
  TransportRequest[] listByStatus(TenantId tenantId, string statusStr);

}
