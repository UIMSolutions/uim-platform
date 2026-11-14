/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Publishing, consumption and webhook delivery.
module uim.platform.events.application.dtos.messaging;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct PublishEventRequest {
  TenantId tenantId;
  UserId actor;
  string serviceId; /// optional if clientId is given
  string clientId; /// optional publishing client (must hold a publish binding)
  string topic;
  string payload;
  string contentType = "application/json";
}

struct PublishResult {
  string messageId; /// id shared by all copies
  string topic;
  string[] queueIds; /// queues that accepted the message
  string[] rejectedQueueIds; /// matching queues that were full or closed
}

struct ConsumeMessagesRequest {
  TenantId tenantId;
  UserId actor;
  QueueId queueId;
  string clientId; /// optional consuming client (must hold a subscribe binding)
  int maxMessages = 10;
}

struct DeliveryResult {
  string webhookId;
  string webhookName;
  size_t attempted;
  size_t delivered;
  size_t retried;
  size_t deadLettered;
  size_t discarded;
  string lastError;
}
