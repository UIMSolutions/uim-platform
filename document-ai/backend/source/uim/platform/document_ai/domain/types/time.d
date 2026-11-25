/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set".
module uim.platform.document_ai.domain.types.time;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecondL = 10_000_000;
enum long hnsecsPerMilliL = 10_000;
enum long hnsecsPerDayL = 86_400L * hnsecsPerSecondL;

long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + seconds (negative: back)
long plusSeconds(long stdTime, long seconds) pure {
  return stdTime + seconds * hnsecsPerSecondL;
}

/// std time + days (negative: back)
long plusDays(long stdTime, long days) pure {
  return stdTime + days * hnsecsPerDayL;
}

/// Milliseconds between two std times (0 if one is not set or negative).
long millisBetween(long from, long to) pure {
  return from > 0 && to > from ? (to - from) / hnsecsPerMilliL : 0;
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
    throw DaiException.invalid(what ~ " '" ~ text ~ "' is not an ISO 8601 date (YYYY-MM-DD) or date-time");
  }
}

/// std time → ISO 8601 (UTC, seconds), "" for 0.
string isoTimeText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return SysTime(stdTime - stdTime % hnsecsPerSecondL, UTC()).toISOExtString;
}

/// std time → ISO 8601 date ("2026-01-31"), "" for 0.
string isoDateText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return (cast(Date) SysTime(stdTime, UTC())).toISOExtString;
}

///
unittest {
  auto t = parseIsoTime("2026-01-02T03:04:05Z");
  assert(isoTimeText(t) == "2026-01-02T03:04:05Z" && isoDateText(t) == "2026-01-02");
  assert(isoTimeText(plusDays(parseIsoTime("2026-12-31"), 1)) == "2027-01-01T00:00:00Z");
  assert(millisBetween(t, plusSeconds(t, 2)) == 2000 && millisBetween(0, t) == 0);
  assert(parseIsoTime("") == 0 && isoTimeText(0) == "");
  assert(failsWith(DaiErrorKind.invalid, () { parseIsoTime("31.01.2026"); }));
}
