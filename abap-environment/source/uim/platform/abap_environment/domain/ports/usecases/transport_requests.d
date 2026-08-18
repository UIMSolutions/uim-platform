/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.transport_requests;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for transport request management (CTS-like).
interface IManageTransportRequestsUseCase { 

  UsecaseResult createTransportRequest(CreateTransportRequestRequest req);
  UsecaseResult addTransportTask(AddTransportTaskRequest req);
  UsecaseResult releaseTransportTask(TenantId tenantId, TransportRequestId requestId, TransportTaskId taskId);
  UsecaseResult releaseTransportRequest(TenantId tenantId, TransportRequestId id);
  TransportRequest getTransportRequest(TenantId tenantId, TransportRequestId id);
  TransportRequest[] listTransportRequests(TenantId tenantId, SystemInstanceId systemId);
  TransportRequest[] listTransportRequests(TenantId tenantId, SystemInstanceId systemId, TransportStatus status);
  UsecaseResult deleteTransportRequest(TenantId tenantId, TransportRequestId id);

}
