/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dtos.queue_subscription;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct CreateQueueSubscriptionRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string queueId;
  string name;
  string description;
  string topicPattern;
}

struct UpdateQueueSubscriptionRequest {
  TenantId tenantId;
  UserId actor;
  QueueSubscriptionId id;

  Patch!(string) name;
  Patch!(string) description;
  Patch!(string) status;
  Patch!(string) topicPattern;
}
