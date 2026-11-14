/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.enumerations.message;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// State of a message stored in a queue.
enum QueueMessageState : string {
  queued = "queued",
  deadLettered = "deadLettered"
}
