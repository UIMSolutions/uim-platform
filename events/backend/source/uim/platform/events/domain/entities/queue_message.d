/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.queue_message;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// A message stored in a queue (createdAt = publish time).
struct QueueMessage {
  mixin TenantEntity!QueueMessageId;

  QueueId queueId;
  MessagingServiceId serviceId;
  string correlationId; /// shared by all copies of one published event
  string topic;
  string payload;
  string contentType = "application/json";
  QueueMessageState state = QueueMessageState.queued;
  int deliveryCount; /// failed delivery attempts so far
  long expiresAt; /// std time, 0 = never
  MessageClientId publisherId; /// publishing client, if any
  QueueId originalQueueId; /// set when the message was dead-lettered
  string lastError;

  bool isExpired(long now) const {
    return expiresAt > 0 && now >= expiresAt;
  }

  size_t size() const {
    return payload.length;
  }
}
