/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dtos.messaging_service;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct CreateMessagingServiceRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string name;
  string description;
  string namespace;
  string plan;
  string region;
  int maxConnections;
  int maxQueues;
  int maxQueueDepth;
  long maxMessageSize;
  string tokenEndpoint;
  string messagingEndpoint;
}

struct UpdateMessagingServiceRequest {
  TenantId tenantId;
  UserId actor;
  MessagingServiceId id;

  Patch!(string) name;
  Patch!(string) description;
  Patch!(string) status;
  Patch!(string) plan;
  Patch!(string) region;
  Patch!(int) maxConnections;
  Patch!(int) maxQueues;
  Patch!(int) maxQueueDepth;
  Patch!(long) maxMessageSize;
  Patch!(string) tokenEndpoint;
  Patch!(string) messagingEndpoint;
}
