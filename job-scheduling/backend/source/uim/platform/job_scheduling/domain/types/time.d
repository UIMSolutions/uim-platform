/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set". All schedules are evaluated in UTC.
module uim.platform.job_scheduling.domain.types.time;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

enum long hnsecsPerMsL = 10_000;
enum long hnsecsPerSecondL = 10_000_000;
enum long hnsecsPerMinuteL = 60 * hnsecsPerSecondL;
enum long hnsecsPerDayL = 86_400L * hnsecsPerSecondL;

long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + seconds
long plusSeconds(long stdTime, long seconds) pure {
  return stdTime + seconds * hnsecsPerSecondL;
}

/// std time + days (negative: back)
long plusDays(long stdTime, long days) pure {
  return stdTime + days * hnsecsPerDayL;
}

/// Whole milliseconds between two std times (0 if one is unset).
long millisBetween(long from, long to) pure {
  return from > 0 && to >= from ? (to - from) / hnsecsPerMsL : 0;
}

/// The std time cut to whole seconds.
long truncateToSecond(long stdTime) pure {
  return stdTime - stdTime % hnsecsPerSecondL;
}

/// The std time cut to whole minutes.
long truncateToMinute(long stdTime) pure {
  return stdTime - stdTime % hnsecsPerMinuteL;
}

/// Midnight (UTC) of the day of a std time.
long startOfDay(long stdTime) pure {
  return stdTime - stdTime % hnsecsPerDayL;
}

/// ISO 8601 date ("2026-01-31") or date-time ("2026-01-31T10:00:00Z") →
/// std time (UTC); 0 for "". Throws invalid on garbage.
long parseIsoTime(string text, string what = "Date") @trusted {
  auto t = text.strip;
  if (t.length == 0)
    return 0;
  try {
    if (t.length == 10)
      return SysTime(Date.fromISOExtString(t), UTC()).stdTime;
    if (!t.endsWith("Z") && t.indexOf('+') < 0 && t.lastIndexOf('-') <= 7) // no zone: UTC
      t ~= "Z";
    return SysTime.fromISOExtString(t).toUTC.stdTime;
  } catch (Exception) {
    throw JobSchedulingException.invalid(what ~ " '" ~ text ~ "' is not an ISO 8601 date (YYYY-MM-DD) or date-time");
  }
}

/// std time → ISO 8601 (UTC, seconds), "" for 0.
string isoTimeText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return SysTime(truncateToSecond(stdTime), UTC()).toISOExtString;
}

/// std time → ISO 8601 date (UTC), "" for 0.
string isoDateText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return (cast(Date) SysTime(stdTime, UTC())).toISOExtString;
}

///
unittest {
  auto t = parseIsoTime("2026-01-02T03:04:05Z");
  assert(isoTimeText(t) == "2026-01-02T03:04:05Z" && isoDateText(t) == "2026-01-02");
  assert(parseIsoTime("2026-01-02T03:04:05") == t);
  assert(isoDateText(parseIsoTime("2026-01-31")) == "2026-01-31");
  assert(isoDateText(plusDays(parseIsoTime("2026-12-31"), 1)) == "2027-01-01");
  assert(startOfDay(t) == parseIsoTime("2026-01-02") && truncateToMinute(t) == parseIsoTime("2026-01-02T03:04:00Z"));
  assert(millisBetween(t, plusSeconds(t, 2)) == 2000 && millisBetween(0, t) == 0);
  assert(parseIsoTime("") == 0 && isoTimeText(0) == "" && isoDateText(0) == "");
  assert(failsWith(JsErrorKind.invalid, () { parseIsoTime("31.01.2026"); }));
}
