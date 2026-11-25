/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Repeat intervals ("10 minutes", "2h", "90s") and times of day
/// ("14:30", "4.40pm") of recurring schedules.
module uim.platform.job_scheduling.domain.types.intervals;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

/// Upper bound of a repeat interval: one year.
enum long maxIntervalSeconds = 366L * 86_400;

/// Seconds of a unit name ("min", "minutes", "h", …); 0 if unknown.
long unitSeconds(string unit) pure {
  switch (unit.toLower) {
  case "s", "sec", "secs", "second", "seconds":
    return 1;
  case "m", "min", "mins", "minute", "minutes":
    return 60;
  case "h", "hr", "hrs", "hour", "hours":
    return 3600;
  case "d", "day", "days":
    return 86_400;
  case "w", "week", "weeks":
    return 7 * 86_400;
  default:
    return 0;
  }
}

/// "10 minutes", "10minutes", "2h", "90 s", "1 day" → seconds. Throws invalid.
long parseInterval(string text) {
  auto t = text.strip;
  size_t digits;
  while (digits < t.length && t[digits] >= '0' && t[digits] <= '9')
    digits++;
  long n;
  long unit;
  if (digits > 0 && digits <= 9) {
    n = t[0 .. digits].to!long;
    unit = unitSeconds(t[digits .. $].strip);
  }
  if (n <= 0 || unit == 0)
    throw JobSchedulingException.invalid("Repeat interval '" ~ text
        ~ "' must be a positive number with a unit (seconds, minutes, hours, days, weeks), e.g. '10 minutes'");
  auto seconds = n * unit;
  if (seconds > maxIntervalSeconds)
    throw JobSchedulingException.invalid("Repeat interval '" ~ text ~ "' is longer than one year");
  return seconds;
}

/// Seconds → "10 minutes", "1 hour", "90 seconds" (largest exact unit).
string intervalText(long seconds) {
  foreach (u; [tuple(7L * 86_400, "week"), tuple(86_400L, "day"), tuple(3600L, "hour"), tuple(60L, "minute")])
    if (seconds >= u[0] && seconds % u[0] == 0) {
      auto n = seconds / u[0];
      return format("%d %s%s", n, u[1], n == 1 ? "" : "s");
    }
  return format("%d second%s", seconds, seconds == 1 ? "" : "s");
}

/// "14:30", "14:30:15", "4:40pm", "4.40 PM", "9am" → seconds after midnight (UTC). Throws invalid.
long parseTimeOfDay(string text) {
  auto t = text.strip.toLower.replace(" ", "");
  int offset = -1;
  if (t.endsWith("am") || t.endsWith("pm")) {
    offset = t.endsWith("pm") ? 12 : 0;
    t = t[0 .. $ - 2];
  }
  auto parts = t.split!(c => c == ':' || c == '.');
  try {
    if (parts.length >= 1 && parts.length <= 3 && parts.all!(p => p.length > 0 && p.length <= 2 && p.all!(c => c >= '0' && c <= '9'))) {
      auto h = parts[0].to!int;
      auto m = parts.length > 1 ? parts[1].to!int : 0;
      auto s = parts.length > 2 ? parts[2].to!int : 0;
      if (offset >= 0) {
        if (h < 1 || h > 12)
          throw new Exception("12h");
        h = h % 12 + offset;
      }
      if ((offset >= 0 || parts.length > 1) && h <= 23 && m <= 59 && s <= 59)
        return h * 3600L + m * 60L + s;
    }
  } catch (Exception) {
  }
  throw JobSchedulingException.invalid("Time of day '" ~ text ~ "' must be HH:MM (UTC, 24h) or h:MMam/pm");
}

/// Seconds after midnight → "HH:MM" or "HH:MM:SS".
string timeOfDayText(long seconds) {
  auto h = seconds / 3600, m = seconds % 3600 / 60, s = seconds % 60;
  return s ? format("%02d:%02d:%02d", h, m, s) : format("%02d:%02d", h, m);
}

///
unittest {
  assert(parseInterval("10 minutes") == 600 && parseInterval("2h") == 7200 && parseInterval("90 s") == 90);
  assert(parseInterval("1 day") == 86_400 && parseInterval("3 weeks") == 3 * 7 * 86_400);
  assert(failsWith(JsErrorKind.invalid, () { parseInterval("0 minutes"); }));
  assert(failsWith(JsErrorKind.invalid, () { parseInterval("ten minutes"); }));
  assert(failsWith(JsErrorKind.invalid, () { parseInterval("5 fortnights"); }));
  assert(failsWith(JsErrorKind.invalid, () { parseInterval("400 days"); }));
  assert(intervalText(600) == "10 minutes" && intervalText(3600) == "1 hour" && intervalText(90) == "90 seconds");

  assert(parseTimeOfDay("14:30") == 14 * 3600 + 30 * 60 && parseTimeOfDay("4.40pm") == 16 * 3600 + 40 * 60);
  assert(parseTimeOfDay("12am") == 0 && parseTimeOfDay("12:15 PM") == 12 * 3600 + 900 && parseTimeOfDay("00:00:05") == 5);
  assert(failsWith(JsErrorKind.invalid, () { parseTimeOfDay("24:00"); }));
  assert(failsWith(JsErrorKind.invalid, () { parseTimeOfDay("13pm"); }));
  assert(failsWith(JsErrorKind.invalid, () { parseTimeOfDay("14"); }));
  assert(timeOfDayText(16 * 3600 + 40 * 60) == "16:40" && timeOfDayText(5) == "00:00:05");
}
