/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A message the hub gave up on (retries exhausted, payload too large,
/// channel deleted …). Operators requeue or discard it.
module uim.platform.application_events.domain.entities.dead_letter_entry;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct DeadLetterEntry {
  mixin TenantEntity!DeadLetterEntryId;

  EventMessageId messageId;
  EventSubscriptionId subscriptionId;
  EventChannelId channelId;
  string eventId;
  string eventType;
  string reason;
  int attempts;
  DeadLetterStatus status = DeadLetterStatus.open;
  long resolvedAt;
  string resolvedBy;

  bool isOpen() const {
    return status == DeadLetterStatus.open;
  }
}

///
unittest {
  DeadLetterEntry d;
  assert(d.isOpen);
  d.status = DeadLetterStatus.discarded;
  assert(!d.isOpen);
}
