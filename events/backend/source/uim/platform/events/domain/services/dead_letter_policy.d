/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.services.dead_letter_policy;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// What happens to a message after a delivery attempt.
enum DeliveryOutcome {
  remove, /// delivered (or QoS 0) → remove from the queue
  retry, /// keep for redelivery
  deadLetter, /// move to the dead letter queue
  discard /// redeliveries exhausted and no dead letter queue
}

/// Decide the outcome of a delivery attempt.
DeliveryOutcome deliveryOutcome(bool succeeded, const QueueMessage m, const EventQueue q, WebhookDeliveryMode mode) {
  if (succeeded || mode == WebhookDeliveryMode.atMostOnce)
    return DeliveryOutcome.remove;
  if (m.deliveryCount + 1 <= q.maxRedeliveryCount)
    return DeliveryOutcome.retry;
  return q.deadLetterQueueId.isNull ? DeliveryOutcome.discard : DeliveryOutcome.deadLetter;
}

///
unittest {
  QueueMessage m;
  EventQueue q;
  q.maxRedeliveryCount = 1;
  assert(deliveryOutcome(true, m, q, WebhookDeliveryMode.atLeastOnce) == DeliveryOutcome.remove);
  assert(deliveryOutcome(false, m, q, WebhookDeliveryMode.atMostOnce) == DeliveryOutcome.remove);
  assert(deliveryOutcome(false, m, q, WebhookDeliveryMode.atLeastOnce) == DeliveryOutcome.retry);
  m.deliveryCount = 1;
  assert(deliveryOutcome(false, m, q, WebhookDeliveryMode.atLeastOnce) == DeliveryOutcome.discard);
  q.deadLetterQueueId = QueueId("dlq");
  assert(deliveryOutcome(false, m, q, WebhookDeliveryMode.atLeastOnce) == DeliveryOutcome.deadLetter);
}
