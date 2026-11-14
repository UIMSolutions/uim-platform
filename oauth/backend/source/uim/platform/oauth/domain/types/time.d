/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store timestamps as std time (hnsecs since 0001-01-01 UTC);
/// JWT claims use Unix seconds.
module uim.platform.oauth.domain.types.time;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecond = 10_000_000;

/// std time of 1970-01-01T00:00:00Z.
enum long unixEpochStdTime = 621_355_968_000_000_000;

/// Current time in std time.
long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + seconds (0 seconds → 0 = "never").
long expiryAfter(long from, long seconds) pure {
  return seconds > 0 ? from + seconds * hnsecsPerSecond : 0;
}

/// std time → Unix seconds (0 stays 0).
long unixSecondsOf(long stdTime) pure {
  return stdTime > 0 ? (stdTime - unixEpochStdTime) / hnsecsPerSecond : 0;
}

/// True if an expiry (0 = never) lies at or before now.
bool isExpiredAt(long expiresAt, long now) pure {
  return expiresAt > 0 && now >= expiresAt;
}

///
unittest {
  assert(expiryAfter(100, 0) == 0);
  assert(expiryAfter(100, 2) == 100 + 2 * hnsecsPerSecond);
  assert(unixSecondsOf(unixEpochStdTime + 5 * hnsecsPerSecond) == 5);
  assert(!isExpiredAt(0, 1) && isExpiredAt(5, 5) && !isExpiredAt(6, 5));
}
