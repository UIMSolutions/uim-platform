/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.queue_subscription;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Routes events whose topic matches the pattern into a queue.
struct QueueSubscription {
  mixin TenantEntity!QueueSubscriptionId;

  QueueId queueId;
  MessagingServiceId serviceId; /// derived from the queue
  string name;
  string description;
  QueueSubscriptionStatus status = QueueSubscriptionStatus.active;
  string topicPattern; /// e.g. "acme/sales/orders/ce/*"

  bool isActive() const {
    return status == QueueSubscriptionStatus.active;
  }

  void validate() const {
    if (queueId.isNull)
      throw EventsException.invalid("Queue subscription needs a queueId");
    if (!isValidTopicPattern(topicPattern))
      throw EventsException.invalid("Invalid topic pattern '" ~ topicPattern ~ "' (segments, '*' or a trailing '#')");
  }
}
