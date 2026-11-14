/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dtos.queue;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct CreateQueueRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string serviceId;
  string name;
  string description;
  string accessType;
  int maxDepth;
  long maxMessageSize;
  long messageTtlSeconds;
  int maxRedeliveryCount = -1; /// -1 = default (3)
  string deadLetterQueueId;
  bool ingressEnabled = true;
  bool egressEnabled = true;
  string owner;
}

struct UpdateQueueRequest {
  TenantId tenantId;
  UserId actor;
  QueueId id;

  Patch!(string) description;
  Patch!(string) status;
  Patch!(string) accessType;
  Patch!(int) maxDepth;
  Patch!(long) maxMessageSize;
  Patch!(long) messageTtlSeconds;
  Patch!(int) maxRedeliveryCount;
  Patch!(string) deadLetterQueueId;
  Patch!(bool) ingressEnabled;
  Patch!(bool) egressEnabled;
  Patch!(string) owner;
}
