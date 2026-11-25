/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Cron expressions (UTC), the classic five fields:
///
///   minute  hour  day-of-month  month  day-of-week
///   0-59    0-23  1-31          1-12   0-7 (0 and 7 = Sunday)
///
/// Each field: "*", a value, a range "a-b", a list "a,b,c" and steps
/// "*/n", "a-b/n", "a/n". Months and weekdays also accept names (JAN,
/// MON). Macros: @yearly @annually @monthly @weekly @daily @midnight @hourly.
/// If both day-of-month and day-of-week are restricted, either may match
/// (Vixie cron semantics).
module uim.platform.job_scheduling.domain.types.cron;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

/// How far ahead the next run is searched (an expression like "0 0 30 2 *" never matches).
enum long cronSearchDays = 5 * 366;

private enum string[] monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
private enum string[] dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

struct CronExpression {
  bool[60] minutes;
  bool[24] hours;
  bool[32] days; /// 1-31
  bool[13] months; /// 1-12
  bool[7] weekdays; /// 0 = Sunday
  bool dayRestricted;
  bool weekdayRestricted;
  string text; /// normalized expression

  /// Parse; throws JobSchedulingException.invalid with the failing field.
  static CronExpression parse(string expression) {
    auto e = expression.strip;
    switch (e.toLower) {
    case "@yearly", "@annually":
      e = "0 0 1 1 *";
      break;
    case "@monthly":
      e = "0 0 1 * *";
      break;
    case "@weekly":
      e = "0 0 * * 0";
      break;
    case "@daily", "@midnight":
      e = "0 0 * * *";
      break;
    case "@hourly":
      e = "0 * * * *";
      break;
    default:
      break;
    }
    auto parts = e.split!(c => c == ' ' || c == '\t').filter!(p => p.length > 0).array;
    if (parts.length != 5)
      throw JobSchedulingException.invalid("Cron expression '" ~ expression
          ~ "' must have 5 fields: minute hour day-of-month month day-of-week");
    CronExpression c;
    parseField(parts[0], 0, 59, null, c.minutes[], "minute");
    parseField(parts[1], 0, 23, null, c.hours[], "hour");
    parseField(parts[2], 1, 31, null, c.days[], "day-of-month");
    parseField(parts[3], 1, 12, monthNames, c.months[], "month");
    bool[8] dow;
    parseField(parts[4], 0, 7, dayNames, dow[], "day-of-week");
    foreach (i; 0 .. 7)
      c.weekdays[i] = dow[i];
    if (dow[7])
      c.weekdays[0] = true;
    c.dayRestricted = parts[2] != "*" && parts[2] != "?";
    c.weekdayRestricted = parts[4] != "*" && parts[4] != "?";
    c.text = parts.join(" ");
    return c;
  }

  /// True if the minute of the std time matches.
  bool matches(long stdTime) const @trusted {
    auto t = SysTime(stdTime, UTC());
    return months[t.month] && dayMatches(t) && hours[t.hour] && minutes[t.minute];
  }

  protected bool dayMatches(SysTime t) const @trusted {
    auto dom = days[t.day];
    auto dow = weekdays[cast(int) t.dayOfWeek];
    if (dayRestricted && weekdayRestricted)
      return dom || dow;
    return dom && dow;
  }

  /// The first matching minute strictly after `after`; 0 if none within cronSearchDays.
  long next(long after) const @trusted {
    auto t = SysTime(truncateToMinute(after) + hnsecsPerMinuteL, UTC());
    auto limit = t + dur!"days"(cronSearchDays);
    while (t < limit) {
      if (!months[t.month]) {
        auto d = Date(t.year, t.month, 1);
        d.add!"months"(1);
        t = SysTime(DateTime(d, TimeOfDay(0, 0, 0)), UTC());
        continue;
      }
      if (!dayMatches(t)) {
        t = SysTime(DateTime(cast(Date) t, TimeOfDay(0, 0, 0)), UTC()) + dur!"days"(1);
        continue;
      }
      if (!hours[t.hour]) {
        t = SysTime(DateTime(cast(Date) t, TimeOfDay(t.hour, 0, 0)), UTC()) + dur!"hours"(1);
        continue;
      }
      if (!minutes[t.minute]) {
        t += dur!"minutes"(1);
        continue;
      }
      return t.stdTime;
    }
    return 0;
  }

  /// The next n matching minutes after `after`.
  long[] upcoming(long after, size_t n) const {
    long[] result;
    auto t = after;
    foreach (_; 0 .. n) {
      t = next(t);
      if (t == 0)
        break;
      result ~= t;
    }
    return result;
  }
}

private void parseField(string field, int min, int max, const string[] names, bool[] target, string what) {
  int value(string s) {
    auto u = s.strip.toUpper;
    foreach (i, n; names)
      if (n == u)
        return cast(int)(i + (min == 1 ? 1 : 0));
    try {
      auto v = s.strip.to!int;
      if (v < min || v > max)
        throw new Exception("range");
      return v;
    } catch (Exception) {
      throw JobSchedulingException.invalid(format("Cron %s '%s' is invalid (allowed: %d-%d)", what, s, min, max));
    }
  }

  foreach (item; field.split(",")) {
    if (item.length == 0)
      throw JobSchedulingException.invalid("Cron " ~ what ~ " '" ~ field ~ "' has an empty list item");
    int step = 1;
    auto range = item;
    auto slash = item.indexOf('/');
    if (slash >= 0) {
      try
        step = item[slash + 1 .. $].to!int;
      catch (Exception)
        step = 0;
      if (step <= 0)
        throw JobSchedulingException.invalid("Cron " ~ what ~ " step in '" ~ item ~ "' must be a positive number");
      range = item[0 .. slash];
    }
    int from, to;
    if (range == "*" || range == "?") {
      from = min;
      to = max;
    } else {
      auto dash = range.indexOf('-');
      if (dash > 0) {
        from = value(range[0 .. dash]);
        to = value(range[dash + 1 .. $]);
        if (from > to)
          throw JobSchedulingException.invalid("Cron " ~ what ~ " range '" ~ range ~ "' is reversed");
      } else {
        from = value(range);
        to = slash >= 0 ? max : from;
      }
    }
    for (int v = from; v <= to; v += step)
      target[v] = true;
  }
}

///
unittest {
  auto at(string s) => parseIsoTime(s);

  auto every5 = CronExpression.parse("*/5 * * * *");
  assert(isoTimeText(every5.next(at("2026-03-01T10:02:30Z"))) == "2026-03-01T10:05:00Z");
  assert(isoTimeText(every5.next(at("2026-03-01T10:05:00Z"))) == "2026-03-01T10:10:00Z");

  auto weekdays = CronExpression.parse("30 9 * * MON-FRI");
  // 2026-03-07 is a Saturday → Monday 2026-03-09
  assert(isoTimeText(weekdays.next(at("2026-03-06T10:00:00Z"))) == "2026-03-09T09:30:00Z");

  auto monthly = CronExpression.parse("@monthly");
  assert(isoTimeText(monthly.next(at("2026-01-31T12:00:00Z"))) == "2026-02-01T00:00:00Z");
  assert(monthly.text == "0 0 1 * *");

  auto leap = CronExpression.parse("0 12 29 2 *");
  assert(isoTimeText(leap.next(at("2026-03-01T00:00:00Z"))) == "2028-02-29T12:00:00Z");
  assert(CronExpression.parse("0 0 30 2 *").next(at("2026-01-01")) == 0);

  // day-of-month OR day-of-week if both are restricted
  auto either = CronExpression.parse("0 0 13 * 5");
  assert(isoTimeText(either.next(at("2026-03-01T00:00:00Z"))) == "2026-03-06T00:00:00Z"); // a Friday before the 13th
  assert(CronExpression.parse("0 0 * * 7").weekdays[0]);
  assert(CronExpression.parse("15,45 */6 1-10/3 jan,jul *").upcoming(at("2026-01-01"), 3).length == 3);

  assert(failsWith(JsErrorKind.invalid, () { CronExpression.parse("* * * *"); }));
  assert(failsWith(JsErrorKind.invalid, () { CronExpression.parse("60 * * * *"); }));
  assert(failsWith(JsErrorKind.invalid, () { CronExpression.parse("*/0 * * * *"); }));
  assert(failsWith(JsErrorKind.invalid, () { CronExpression.parse("5-1 * * * *"); }));
  assert(failsWith(JsErrorKind.invalid, () { CronExpression.parse("* * * FOO *"); }));
}
