/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set".
module uim.platform.ai_core.domain.types.time;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecondL = 10_000_000;

long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + seconds
long plusSeconds(long stdTime, long seconds) pure {
  return stdTime + seconds * hnsecsPerSecondL;
}

/// Whole seconds from a to b (negative if b is earlier).
long secondsBetween(long a, long b) pure {
  return (b - a) / hnsecsPerSecondL;
}

/// ISO 8601 (UTC, seconds) → std time; 0 for "" and throws on garbage.
long parseIsoTime(string text) @trusted {
  auto t = text.strip;
  if (t.length == 0)
    return 0;
  return SysTime.fromISOExtString(t).toUTC.stdTime;
}

/// std time → ISO 8601 (UTC, seconds), "" for 0.
string isoTimeText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return SysTime(stdTime - stdTime % hnsecsPerSecondL, UTC()).toISOExtString;
}

///
unittest {
  auto t = parseIsoTime("2026-01-02T03:04:05Z");
  assert(isoTimeText(t) == "2026-01-02T03:04:05Z");
  assert(secondsBetween(t, plusSeconds(t, 90)) == 90);
  assert(parseIsoTime("") == 0 && isoTimeText(0) == "");
}
