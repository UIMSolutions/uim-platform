/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.transport_request;

// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// A request to transport one or more content packages between landscapes.
struct TransportRequest {
  TenantId tenantId;
  TransportRequestId id;
  SubaccountId sourceSubaccount;
  SubaccountId targetSubaccount;
  string description;
  TransportStatus status = TransportStatus.created;
  TransportMode mode = TransportMode.cloudTransportManagement;
  ContentPackageId[] packageIds;
  TransportQueueId queueId;
  UserId createdBy;
  long createdAt;
  long updatedAt;
  long releasedAt;
  string errorMessage;
}
