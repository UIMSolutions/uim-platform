/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations and status values. All enumerations are string
/// valued: the value is what the APIs accept and return.
module uim.platform.application_events.domain.enumerations.eventhub;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// A formation groups the systems of a customer landscape that exchange events.
enum FormationStatus : string {
  active = "active",
  inactive = "inactive" /// no events are routed between its systems
}

/// Role of a registered system.
enum SystemType : string {
  producer = "producer",
  consumer = "consumer",
  both = "both"
}

bool canProduce(SystemType t) pure {
  return t == SystemType.producer || t == SystemType.both;
}

bool canConsume(SystemType t) pure {
  return t == SystemType.consumer || t == SystemType.both;
}

enum SystemStatus : string {
  active = "active",
  inactive = "inactive" /// may neither publish nor receive events
}

/// Life cycle of an event type in the catalog.
enum TopicStatus : string {
  active = "active",
  deprecated_ = "deprecated", /// still published and delivered; no new subscriptions
  retired = "retired" /// events of the type are refused
}

/// How a channel hands messages to the consumer.
enum ChannelType : string {
  webhook = "webhook", /// HTTP POST of the CloudEvent to the endpoint (push)
  queue = "queue" /// kept until the consumer pulls and acknowledges (pull)
}

enum ChannelStatus : string {
  active = "active",
  inactive = "inactive", /// nothing is delivered; new messages wait (pending)
  draining = "draining" /// no new messages; the queued / pending ones are still delivered
}

/// Delivery guarantee of a channel.
enum DeliveryMode : string {
  atLeastOnce = "atLeastOnce", /// retries with back-off, then dead letter
  atMostOnce = "atMostOnce" /// one attempt; a failed message is dropped
}

enum SubscriptionStatus : string {
  active = "active",
  paused = "paused" /// matching events are not routed to the consumer
}

/// Include filters must all match; one matching exclude filter rejects.
enum FilterType : string {
  include = "include",
  exclude = "exclude"
}

enum EventFilterOperator : string {
  equals = "equals",
  notEquals = "notEquals",
  contains = "contains",
  startsWith = "startsWith",
  endsWith = "endsWith",
  exists = "exists", /// the attribute is present (value ignored)
  oneOf = "oneOf" /// comma separated list of values
}

/// State of one delivery (a message = an event routed to one subscription).
enum MessageStatus : string {
  pending = "pending", /// waiting for the first attempt
  retrying = "retrying", /// failed; the next attempt is scheduled (nextAttemptAt)
  queued = "queued", /// in a queue channel, waiting for the consumer's acknowledgement
  delivered = "delivered",
  deadLettered = "deadLettered", /// given up; a dead letter entry exists
  dropped = "dropped" /// at-most-once delivery failed
}

/// True while a message can still be delivered.
bool isOpen(MessageStatus s) pure {
  return s == MessageStatus.pending || s == MessageStatus.retrying || s == MessageStatus.queued;
}

enum DeadLetterStatus : string {
  open = "open", /// waits for an operator
  requeued = "requeued", /// sent again (the message is pending / delivered again)
  discarded = "discarded"
}

///
unittest {
  assert(canProduce(SystemType.both) && !canProduce(SystemType.consumer) && canConsume(SystemType.consumer));
  assert(isOpen(MessageStatus.retrying) && !isOpen(MessageStatus.delivered));
  assert(cast(string) TopicStatus.deprecated_ == "deprecated");
}
