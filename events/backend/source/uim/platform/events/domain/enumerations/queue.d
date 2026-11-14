/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.enumerations.queue;

import uim.platform.events;

mixin(ShowModule!());

@safe:

enum QueueStatus : string {
  active = "active",
  inactive = "inactive",
  pendingDelete = "pendingDelete"
}

/// exclusive: one consumer at a time; nonExclusive: round robin.
enum QueueAccessType : string {
  exclusive = "exclusive",
  nonExclusive = "nonExclusive"
}

enum QueueSubscriptionStatus : string {
  active = "active",
  inactive = "inactive"
}
