/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.queue;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// A durable queue of a messaging service. Topic subscriptions route
/// published events into it; consumers and webhooks drain it.
struct EventQueue {
  mixin TenantEntity!QueueId;

  MessagingServiceId serviceId;
  string name;
  string description;
  QueueStatus status = QueueStatus.active;
  QueueAccessType accessType = QueueAccessType.nonExclusive;
  int maxDepth; /// max. queued messages, 0 = service quota
  long maxMessageSize; /// bytes, 0 = service quota
  long messageTtlSeconds; /// 0 = no expiry
  int maxRedeliveryCount = 3; /// failed deliveries before dead-lettering
  QueueId deadLetterQueueId; /// target of messages that exceed maxRedeliveryCount
  bool ingressEnabled = true; /// accepts new messages
  bool egressEnabled = true; /// messages may be consumed
  string owner;

  bool acceptsMessages() const {
    return status == QueueStatus.active && ingressEnabled;
  }

  bool deliversMessages() const {
    return status == QueueStatus.active && egressEnabled;
  }

  void validate() const {
    import std.ascii : isAlphaNum;

    requireText(name, "Queue name");
    if (!name.all!(c => c.isAlphaNum || "-_./".canFind(c)))
      throw EventsException.invalid("Queue name '" ~ name ~ "' may only contain letters, digits and - _ . /");
    if (serviceId.isNull)
      throw EventsException.invalid("Queue needs a serviceId");
    requireNonNegative(maxDepth, "maxDepth");
    requireNonNegative(maxMessageSize, "maxMessageSize");
    requireNonNegative(messageTtlSeconds, "messageTtlSeconds");
    requireNonNegative(maxRedeliveryCount, "maxRedeliveryCount");
    if (!deadLetterQueueId.isNull && deadLetterQueueId == id)
      throw EventsException.invalid("A queue cannot be its own dead letter queue");
  }
}

///
unittest {
  EventQueue q;
  q.id = QueueId("q1");
  q.serviceId = MessagingServiceId("s1");
  q.name = "acme/sales/orders/created";
  q.validate();
  q.deadLetterQueueId = QueueId("q1");
  assert(failsWith(EventsErrorKind.invalid, () { q.validate(); }));
  q.deadLetterQueueId = QueueId.init;
  q.name = "bad name";
  assert(failsWith(EventsErrorKind.invalid, () { q.validate(); }));
}
