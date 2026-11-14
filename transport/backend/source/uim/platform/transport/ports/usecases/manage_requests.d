/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.usecases.manage_requests;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driving port: register and maintain transport requests.
interface IManageTransportRequestsUseCase {
  UsecaseResult createRequest(CreateRequestInput input);
  UsecaseResult updateRequest(UpdateRequestInput input);
  UsecaseResult updateRequestStatus(TenantId tenantId, TransportRequestId id, RequestStatus status);
  /// Deletes the request and its queue entries; fails (422) while an import is running.
  UsecaseResult deleteRequest(TenantId tenantId, TransportRequestId id, string performedBy = "");

  bool hasRequest(TenantId tenantId, TransportRequestId id);
  TransportRequest getRequest(TenantId tenantId, TransportRequestId id);
  TransportRequest[] listRequests(TenantId tenantId);
  TransportRequest[] listRequestsByStatus(TenantId tenantId, RequestStatus status);
  TransportRequest[] listRequestsByNode(TenantId tenantId, TransportNodeId nodeId);
}
