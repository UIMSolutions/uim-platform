/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store timestamps as std time (hnsecs since 0001-01-01 UTC).
module uim.platform.events.domain.types.time;

import uim.platform.events;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecond = 10_000_000;

/// Current time in std time.
long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + seconds (0 seconds → 0 = "never").
long expiryAfter(long from, long seconds) {
  return seconds > 0 ? from + seconds * hnsecsPerSecond : 0;
}

///
unittest {
  assert(expiryAfter(100, 0) == 0);
  assert(expiryAfter(100, 2) == 100 + 2 * hnsecsPerSecond);
}
