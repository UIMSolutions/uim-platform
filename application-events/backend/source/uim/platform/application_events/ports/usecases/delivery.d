/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the delivery: messages, queue consumers, dead letters.
module uim.platform.application_events.ports.usecases.delivery;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

interface IDeliverMessages {
  /// Attempt every due message (pending, or retrying with nextAttemptAt reached).
  DispatchSummary dispatchDue(TenantId t, UserId actor);
  /// Attempt one open message now (ignores the back-off).
  DeliveryResult deliverNow(TenantId t, EventMessageId id, UserId actor);
  /// Queue channels: the queued messages, oldest first (they stay queued).
  EventMessage[] pull(TenantId t, EventChannelId channel, size_t max, UserId actor);
  /// Queue channels: the consumer confirms a message (→ delivered).
  EventMessage acknowledge(TenantId t, EventMessageId id, UserId actor);
  EventMessage getMessage(TenantId t, EventMessageId id);
  EventMessage[] listMessages(TenantId t);
  /// Remove finished messages and resolved dead letters beyond their retention.
  PurgeResult purge(TenantId t, UserId actor);
}

interface IManageDeadLetters {
  DeadLetterEntry get(TenantId t, DeadLetterEntryId id);
  DeadLetterEntry[] list(TenantId t);
  /// Send the message again (attempts reset); the entry becomes requeued.
  DeliveryResult requeue(TenantId t, DeadLetterEntryId id, UserId actor);
  /// Requeue all open entries (of one subscription, or all); returns the count.
  DispatchSummary requeueAll(TenantId t, EventSubscriptionId subscription, UserId actor);
  DeadLetterEntry discard(TenantId t, DeadLetterEntryId id, UserId actor);
}
