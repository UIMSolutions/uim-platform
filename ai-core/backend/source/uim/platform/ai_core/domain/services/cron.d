/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// 5 field cron expressions (minute hour day-of-month month day-of-week,
/// UTC) with "*", lists, ranges and steps. Like Vixie cron, a restricted
/// day-of-month and day-of-week match if either matches.
module uim.platform.ai_core.domain.services.cron;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct CronExpression {
  string text;
  bool[60] minutes;
  bool[24] hours;
  bool[32] days;
  bool[13] months;
  bool[7] weekdays;
  bool anyDay = true; /// day-of-month is "*"
  bool anyWeekday = true; /// day-of-week is "*"

  /// Parse; throws AiCoreException.invalid.
  static CronExpression parse(string text) {
    auto fields = text.strip.split!isWhite.filter!(f => f.length > 0).array;
    if (fields.length != 5)
      throw AiCoreException.invalid("Cron expression '" ~ text ~ "' must have 5 fields (minute hour day month weekday)");
    CronExpression c;
    c.text = fields.join(" ");
    fill(c.minutes[], fields[0], 0, 59, "minute");
    fill(c.hours[], fields[1], 0, 23, "hour");
    fill(c.days[], fields[2], 1, 31, "day of month");
    fill(c.months[], fields[3], 1, 12, "month");
    bool[8] dow;
    fill(dow[], fields[4], 0, 7, "day of week");
    foreach (i; 0 .. 7)
      c.weekdays[i] = dow[i];
    if (dow[7])
      c.weekdays[0] = true; // 7 = Sunday
    c.anyDay = fields[2] == "*";
    c.anyWeekday = fields[4] == "*";
    return c;
  }

  /// True if the expression is valid.
  static bool isValid(string text) {
    try {
      parse(text);
      return true;
    } catch (AiCoreException)
      return false;
  }

  bool matches(DateTime t) const {
    return minutes[t.minute] && hours[t.hour] && months[cast(int) t.month] && dayMatches(t);
  }

  /// The first matching minute strictly after the given std time, or 0 if
  /// none exists within four years (e.g. "0 0 31 2 *").
  long next(long afterStdTime) const @trusted {
    auto s = SysTime(afterStdTime, UTC());
    auto t = DateTime(s.year, s.month, s.day, s.hour, s.minute, 0) + dur!"minutes"(1);
    auto limit = t + dur!"days"(4 * 366);
    while (t < limit) {
      if (!months[cast(int) t.month]) {
        t = t.month == Month.dec ? DateTime(t.year + 1, 1, 1) : DateTime(t.year, cast(int) t.month + 1, 1);
        continue;
      }
      if (!dayMatches(t)) {
        t = DateTime(t.date + dur!"days"(1));
        continue;
      }
      if (!hours[t.hour]) {
        t = DateTime(t.year, t.month, t.day, t.hour, 0, 0) + dur!"hours"(1);
        continue;
      }
      if (!minutes[t.minute]) {
        t += dur!"minutes"(1);
        continue;
      }
      return SysTime(t, UTC()).stdTime;
    }
    return 0;
  }

  private bool dayMatches(DateTime t) const {
    auto dom = days[t.day];
    auto dow = weekdays[cast(int) t.dayOfWeek];
    if (anyDay && anyWeekday)
      return true;
    if (anyDay)
      return dow;
    if (anyWeekday)
      return dom;
    return dom || dow;
  }

  private static void fill(bool[] target, string field, int min, int max, string what) {
    foreach (part; field.split(",")) {
      if (part.length == 0)
        throw AiCoreException.invalid("Empty " ~ what ~ " list entry in cron expression");
      int step = 1;
      auto range = part;
      auto slash = part.indexOf('/');
      if (slash >= 0) {
        step = number(part[slash + 1 .. $], 1, max - min + 1, what ~ " step");
        range = part[0 .. slash];
      }
      int lo = min, hi = max;
      if (range != "*") {
        auto dash = range.indexOf('-');
        if (dash >= 0) {
          lo = number(range[0 .. dash], min, max, what);
          hi = number(range[dash + 1 .. $], min, max, what);
          if (hi < lo)
            throw AiCoreException.invalid("Invalid " ~ what ~ " range '" ~ range ~ "'");
        } else {
          lo = number(range, min, max, what);
          hi = slash >= 0 ? max : lo;
        }
      }
      for (int v = lo; v <= hi; v += step)
        target[v] = true; // arrays are sized max + 1
    }
  }

  private static int number(string text, int min, int max, string what) {
    int v;
    try
      v = text.to!int;
    catch (Exception)
      throw AiCoreException.invalid("Invalid " ~ what ~ " '" ~ text ~ "' in cron expression");
    if (v < min || v > max)
      throw AiCoreException.invalid(format("%s %d out of range %d-%d", what, v, min, max));
    return v;
  }
}

///
unittest {
  auto base = parseIsoTime("2026-03-10T10:17:30Z"); // a Tuesday

  auto hourly = CronExpression.parse("0 * * * *");
  assert(isoTimeText(hourly.next(base)) == "2026-03-10T11:00:00Z");

  auto quarter = CronExpression.parse("*/15 9-17 * * 1-5");
  assert(isoTimeText(quarter.next(base)) == "2026-03-10T10:30:00Z");

  auto nightly = CronExpression.parse("30 2 * * *");
  assert(isoTimeText(nightly.next(base)) == "2026-03-11T02:30:00Z");

  auto sunday = CronExpression.parse("0 0 * * 7");
  assert(isoTimeText(sunday.next(base)) == "2026-03-15T00:00:00Z");

  auto monthly = CronExpression.parse("0 6 1 * *");
  assert(isoTimeText(monthly.next(base)) == "2026-04-01T06:00:00Z");

  auto either = CronExpression.parse("0 0 13 * 5"); // the 13th or any Friday
  assert(isoTimeText(either.next(base)) == "2026-03-13T00:00:00Z");

  assert(CronExpression.parse("0 0 31 2 *").next(base) == 0);
  foreach (bad; ["", "* * * *", "60 * * * *", "* 24 * * *", "5-1 * * * *", "*/0 * * * *", "a * * * *", "1,,2 * * * *"])
    assert(!CronExpression.isValid(bad), bad);
}
