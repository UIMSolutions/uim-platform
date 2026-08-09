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

  CommandResult createTransportRequest(CreateTransportRequestRequest req);
  CommandResult addTransportTask(AddTransportTaskRequest req);
  CommandResult releaseTransportTask(TenantId tenantId, TransportRequestId requestId, TransportTaskId taskId);
  CommandResult releaseTransportRequest(TenantId tenantId, TransportRequestId id);
  TransportRequest getTransportRequest(TenantId tenantId, TransportRequestId id);
  TransportRequest[] listTransportRequests(TenantId tenantId, SystemInstanceId systemId);
  TransportRequest[] listTransportRequests(TenantId tenantId, SystemInstanceId systemId, TransportStatus status);
  CommandResult deleteTransportRequest(TenantId tenantId, TransportRequestId id);

}
