/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set".
module uim.platform.datasphere.domain.types.time;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecondL = 10_000_000;
enum long hnsecsPerMinuteL = 60L * hnsecsPerSecondL;
enum long hnsecsPerHourL = 60L * hnsecsPerMinuteL;
enum long hnsecsPerDayL = 24L * hnsecsPerHourL;

long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + seconds (negative: back)
long plusSeconds(long stdTime, long seconds) pure {
  return stdTime + seconds * hnsecsPerSecondL;
}

/// std time + minutes (negative: back)
long plusMinutes(long stdTime, long minutes) pure {
  return stdTime + minutes * hnsecsPerMinuteL;
}

/// std time + days (negative: back)
long plusDays(long stdTime, long days) pure {
  return stdTime + days * hnsecsPerDayL;
}

/// std time + calendar months (the day is clamped to the month's length).
long plusMonths(long stdTime, int months) @trusted {
  auto t = SysTime(stdTime, UTC());
  t.add!"months"(months, AllowDayOverflow.no);
  return t.stdTime;
}

/// Whole milliseconds from one std time to another.
long millisBetween(long from, long to) pure {
  return (to - from) / 10_000;
}

/// ISO 8601 date ("2026-01-31") or date-time ("2026-01-31T10:00:00Z") →
/// std time (UTC); 0 for "". Throws invalid on garbage.
long parseIsoTime(string text, string what = "Time") @trusted {
  auto t = text.strip;
  if (t.length == 0)
    return 0;
  try {
    if (t.length == 10)
      return SysTime(Date.fromISOExtString(t), UTC()).stdTime;
    return SysTime.fromISOExtString(t).toUTC.stdTime;
  } catch (Exception) {
    throw DspException.invalid(what ~ " '" ~ text ~ "' is not an ISO 8601 date (YYYY-MM-DD) or date-time");
  }
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
  assert(isoTimeText(plusDays(parseIsoTime("2026-12-31"), 1)) == "2027-01-01T00:00:00Z");
  assert(isoTimeText(plusMonths(parseIsoTime("2026-01-31"), 1)) == "2026-02-28T00:00:00Z");
  assert(millisBetween(t, plusSeconds(t, 2)) == 2000 && parseIsoTime("") == 0 && isoTimeText(0) == "");
  assert(failsWith(DspErrorKind.invalid, () { parseIsoTime("31.01.2026"); }));
}
