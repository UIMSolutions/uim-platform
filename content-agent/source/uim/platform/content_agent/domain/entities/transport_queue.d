/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.transport_queue;

// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// A configured transport queue (CTS+, Cloud TMS, or local).
struct TransportQueue {
  TransportQueueId id;
  TenantId tenantId;
  string name;
  string description;
  QueueType queueType = QueueType.cloudTMS;
  string endpoint;
  string authToken;
  bool isDefault;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
