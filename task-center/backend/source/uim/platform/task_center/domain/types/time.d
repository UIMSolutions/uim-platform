/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store timestamps as std time (hnsecs since
/// 0001-01-01 UTC) and calendar days as ISO dates ("YYYY-MM-DD").
module uim.platform.task_center.domain.types.time;

import uim.platform.task_center;

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

/// The UTC calendar day of a std time as "YYYY-MM-DD".
string isoDateOf(long stdTime) @trusted {
  return (cast(Date) SysTime(stdTime, UTC())).toISOExtString;
}

/// Today (UTC) as "YYYY-MM-DD".
string todayIso() {
  return isoDateOf(nowStdTime());
}

/// "YYYY-MM-DD" + days.
string addDays(string isoDate, long days) @trusted {
  return (Date.fromISOExtString(isoDate) + days.days).toISOExtString;
}

/// True for a valid ISO calendar date ("YYYY-MM-DD").
bool isIsoDate(string text) @trusted {
  if (text.length != 10)
    return false;
  try {
    Date.fromISOExtString(text);
    return true;
  } catch (Exception)
    return false;
}

/// The calendar day of an ISO date or timestamp ("2026-11-11T08:00:00Z" → "2026-11-11"), "" if invalid.
string dayOf(string isoDateOrTimestamp) {
  auto t = isoDateOrTimestamp.strip;
  return t.length >= 10 && isIsoDate(t[0 .. 10]) ? t[0 .. 10] : "";
}

///
unittest {
  assert(expiryAfter(100, 0) == 0);
  assert(expiryAfter(100, 2) == 100 + 2 * hnsecsPerSecond);
  assert(isIsoDate("2026-02-28") && !isIsoDate("2026-02-30") && !isIsoDate("26-1-1"));
  assert(addDays("2026-12-30", 3) == "2027-01-02");
  assert(dayOf("2026-11-11T08:00:00Z") == "2026-11-11" && dayOf("soon") == "");
  assert(isIsoDate(todayIso()));
}
