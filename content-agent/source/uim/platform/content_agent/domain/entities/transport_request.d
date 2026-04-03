/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.transport_request;

import uim.platform.content_agent.domain.types;

/// A request to transport one or more content packages between landscapes.
struct TransportRequest
{
  TransportRequestId id;
  TenantId tenantId;
  SubaccountId sourceSubaccount;
  SubaccountId targetSubaccount;
  string description;
  TransportStatus status = TransportStatus.created;
  TransportMode mode = TransportMode.cloudTransportManagement;
  ContentPackageId[] packageIds;
  TransportQueueId queueId;
  string createdBy;
  long createdAt;
  long updatedAt;
  long releasedAt;
  string errorMessage;
}
