/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store timestamps as std time (hnsecs since 0001-01-01 UTC).
module uim.platform.authorization.domain.types.time;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Current time in std time.
long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time n days ago.
long daysAgo(int days) @trusted {
  return nowStdTime() - days * 864_000_000_000L;
}
