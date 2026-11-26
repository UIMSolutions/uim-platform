/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set". Schedules are written in the local time of the
/// policy's time zone (IANA name such as "Europe/Berlin", "UTC" or a fixed
/// offset such as "+01:00").
module uim.platform.application_autoscaler.domain.types.time;

import std.datetime.timezone : PosixTimeZone, SimpleTimeZone, TimeZone;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecondL = 10_000_000;
enum long hnsecsPerMinuteL = 60 * hnsecsPerSecondL;
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

/// Whole seconds from one std time to another (negative if to < from).
long secondsBetween(long from, long to) pure {
  return (to - from) / hnsecsPerSecondL;
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
    throw AasException.invalid(what ~ " '" ~ text ~ "' is not an ISO 8601 date (YYYY-MM-DD) or date-time");
  }
}

/// std time → ISO 8601 (UTC, seconds), "" for 0.
string isoTimeText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return SysTime(stdTime - stdTime % hnsecsPerSecondL, UTC()).toISOExtString;
}

// ── time zones ───────────────────────────────────────────────────────────

/// The time zone of a policy, or null if unknown. Accepts "UTC"/"Z"/"",
/// fixed offsets ("+01:00", "-0530") and IANA names (needs tzdata).
immutable(TimeZone) findTimeZone(string name) @trusted {
  auto n = name.strip;
  if (n.length == 0 || n == "UTC" || n == "Z" || n == "Etc/UTC" || n == "GMT")
    return UTC();
  if (n[0] == '+' || n[0] == '-') {
    auto digits = n[1 .. $].replace(":", "");
    if (digits.length != 4 || !digits.all!(c => c >= '0' && c <= '9'))
      return null;
    auto minutes = digits[0 .. 2].to!int * 60 + digits[2 .. 4].to!int;
    if (minutes > 14 * 60)
      return null;
    return new immutable SimpleTimeZone(dur!"minutes"(n[0] == '-' ? -minutes : minutes));
  }
  try
    return PosixTimeZone.getTimeZone(n);
  catch (Exception)
    return null;
}

bool isValidTimeZone(string name) {
  return findTimeZone(name) !is null;
}

/// The local date and time of a std time in a zone (UTC if unknown).
SysTime localTime(long stdTime, string zone) @trusted {
  auto tz = findTimeZone(zone);
  return SysTime(stdTime, tz !is null ? tz : UTC());
}

/// Local "YYYY-MM-DDTHH:MM[:SS]" in a zone → std time (UTC). Throws invalid.
long parseLocalDateTime(string text, string zone, string what = "Date and time") @trusted {
  auto t = text.strip;
  if (t.length == 16)
    t ~= ":00";
  try {
    auto local = DateTime.fromISOExtString(t);
    auto tz = findTimeZone(zone);
    return SysTime(local, tz !is null ? tz : UTC()).stdTime;
  } catch (Exception) {
    throw AasException.invalid(what ~ " '" ~ text ~ "' is not a local date-time (YYYY-MM-DDTHH:MM)");
  }
}

/// "08:30" → minutes after midnight (0 .. 1439); "24:00" → 1440. Throws invalid.
int parseClockTime(string text, string what = "Time") {
  auto t = text.strip;
  auto ok = t.length == 5 && t[2] == ':' && t[0 .. 2].all!(c => c >= '0' && c <= '9')
    && t[3 .. 5].all!(c => c >= '0' && c <= '9');
  if (ok) {
    auto h = t[0 .. 2].to!int;
    auto m = t[3 .. 5].to!int;
    if ((h < 24 && m < 60) || (h == 24 && m == 0))
      return h * 60 + m;
  }
  throw AasException.invalid(what ~ " '" ~ text ~ "' is not a time of day (HH:MM)");
}

/// ISO day of week: 1 = Monday … 7 = Sunday.
int isoWeekday(DayOfWeek d) pure {
  return d == DayOfWeek.sun ? 7 : cast(int) d;
}

///
unittest {
  auto t = parseIsoTime("2026-01-02T03:04:05Z");
  assert(isoTimeText(t) == "2026-01-02T03:04:05Z");
  assert(isoTimeText(plusDays(parseIsoTime("2026-12-31"), 1)) == "2027-01-01T00:00:00Z");
  assert(secondsBetween(t, plusSeconds(t, 90)) == 90 && parseIsoTime("") == 0 && isoTimeText(0) == "");
  assert(failsWith(AasErrorKind.invalid, () { parseIsoTime("31.01.2026"); }));
  assert(isValidTimeZone("UTC") && isValidTimeZone("+02:00") && isValidTimeZone("-0530") && !isValidTimeZone("+99:00"));
  assert(!isValidTimeZone("Nowhere/Atlantis"));
  assert(parseClockTime("08:30") == 510 && parseClockTime("24:00") == 1440);
  assert(failsWith(AasErrorKind.invalid, () { parseClockTime("8:30"); }));
  assert(failsWith(AasErrorKind.invalid, () { parseClockTime("25:00"); }));
  // 10:00 at +02:00 is 08:00 UTC
  assert(isoTimeText(parseLocalDateTime("2026-06-01T10:00", "+02:00")) == "2026-06-01T08:00:00Z");
  assert(localTime(parseIsoTime("2026-06-01T23:30:00Z"), "+01:00").hour == 0);
  assert(isoWeekday(DayOfWeek.sun) == 7 && isoWeekday(DayOfWeek.mon) == 1);
}
