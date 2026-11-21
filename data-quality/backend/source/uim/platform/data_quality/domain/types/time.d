/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set".
module uim.platform.data_quality.domain.types.time;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecondL = 10_000_000;
enum long hnsecsPerMilliL = 10_000;

long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + seconds
long plusSeconds(long stdTime, long seconds) pure {
  return stdTime + seconds * hnsecsPerSecondL;
}

/// Whole milliseconds from a to b.
long millisBetween(long a, long b) pure {
  return (b - a) / hnsecsPerMilliL;
}

/// ISO 8601 (UTC) → std time; 0 for "" and throws on garbage.
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
  assert(millisBetween(t, plusSeconds(t, 2)) == 2000);
  assert(parseIsoTime("") == 0 && isoTimeText(0) == "");
}
