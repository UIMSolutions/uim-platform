/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set". Calendar arithmetic (months, years) follows the
/// calendar: 31 January + 1 month = 28/29 February, never 2/3 March.
module uim.platform.data_retention.domain.types.time;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecondL = 10_000_000;
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

/// std time + calendar months (negative: back); the day is clamped to the
/// end of the target month.
long plusMonths(long stdTime, long months) @trusted {
  auto t = SysTime(stdTime, UTC());
  t.add!"months"(months, AllowDayOverflow.no);
  return t.stdTime;
}

/// std time + calendar years (29 February → 28 February).
long plusYears(long stdTime, long years) @trusted {
  auto t = SysTime(stdTime, UTC());
  t.add!"years"(years, AllowDayOverflow.no);
  return t.stdTime;
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
    return SysTime.fromISOExtString(t).toUTC.stdTime;
  } catch (Exception) {
    throw DataRetentionException.invalid(what ~ " '" ~ text ~ "' is not an ISO 8601 date (YYYY-MM-DD) or date-time");
  }
}

/// std time → ISO 8601 (UTC, seconds), "" for 0.
string isoTimeText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return SysTime(stdTime - stdTime % hnsecsPerSecondL, UTC()).toISOExtString;
}

/// std time → ISO 8601 date (UTC), "" for 0.
string isoDateText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return (cast(Date) SysTime(stdTime, UTC())).toISOExtString;
}

/// Midnight (UTC) of the day of a std time.
long startOfDay(long stdTime) pure {
  return stdTime - stdTime % hnsecsPerDayL;
}

///
unittest {
  auto t = parseIsoTime("2026-01-02T03:04:05Z");
  assert(isoTimeText(t) == "2026-01-02T03:04:05Z" && isoDateText(t) == "2026-01-02");
  assert(isoDateText(parseIsoTime("2026-01-31")) == "2026-01-31");
  assert(isoDateText(plusMonths(parseIsoTime("2026-01-31"), 1)) == "2026-02-28");
  assert(isoDateText(plusYears(parseIsoTime("2028-02-29"), 1)) == "2029-02-28");
  assert(isoDateText(plusMonths(parseIsoTime("2026-03-15"), -3)) == "2025-12-15");
  assert(isoDateText(plusDays(parseIsoTime("2026-12-31"), 1)) == "2027-01-01");
  assert(startOfDay(t) == parseIsoTime("2026-01-02"));
  assert(parseIsoTime("") == 0 && isoTimeText(0) == "" && isoDateText(0) == "");
  assert(failsWith(DrErrorKind.invalid, () { parseIsoTime("31.01.2026"); }));
}
