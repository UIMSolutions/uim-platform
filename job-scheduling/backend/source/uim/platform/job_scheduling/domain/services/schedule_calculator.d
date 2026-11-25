/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Pure scheduling rules: normalization of schedule expressions (incl.
/// human readable ones) and computation of the next run (UTC).
///
///   cron            "*/5 * * * *"        next matching minute
///   repeatInterval  "10 minutes"         interval after the previous run (or after creation)
///   repeatAt        "14:30"              every day at that time
///   time            "2026-12-01T10:00Z"  once (a time in the past is due immediately)
///
/// Human readable input ("every 10 minutes", "every day at 14:30",
/// "every monday at 8:00", "every weekday at 7:30", "hourly", "in 5 minutes",
/// "now", "at 2026-12-01T10:00:00Z") is converted into one of the above.
/// startTime/endTime restrict the window in which runs happen.
module uim.platform.job_scheduling.domain.services.schedule_calculator;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

/// A normalized schedule rule.
struct ScheduleRule {
  ScheduleFormat format;
  string expression; /// canonical text

  ScheduleType type() const {
    return format == ScheduleFormat.time ? ScheduleType.oneTime : ScheduleType.recurring;
  }
}

private enum string[] weekdayWords = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];

struct ScheduleCalculator {
  /// Validate and normalize; humanReadable becomes one of the other formats.
  /// now resolves relative expressions ("now", "in 5 minutes").
  static ScheduleRule normalize(ScheduleFormat format, string expression, long now) {
    auto e = expression.strip;
    if (e.length == 0)
      throw JobSchedulingException.invalid("The schedule expression is required");
    if (e.length > 256)
      throw JobSchedulingException.invalid("The schedule expression must not exceed 256 characters");
    final switch (format) {
    case ScheduleFormat.cron:
      return ScheduleRule(format, CronExpression.parse(e).text);
    case ScheduleFormat.repeatInterval:
      return ScheduleRule(format, intervalText(parseInterval(e)));
    case ScheduleFormat.repeatAt:
      return ScheduleRule(format, timeOfDayText(parseTimeOfDay(e)));
    case ScheduleFormat.time:
      auto at = e.toLower == "now" ? now : parseIsoTime(e, "Time");
      return ScheduleRule(format, isoTimeText(at));
    case ScheduleFormat.humanReadable:
      return humanReadable(e, now);
    }
  }

  /// "every 10 minutes", "every day at 14:30", … → a rule. Throws invalid.
  static ScheduleRule humanReadable(string text, long now) {
    auto t = text.strip.toLower.split!(c => c == ' ' || c == '\t').filter!(w => w.length > 0).array;
    auto all = t.join(" ");
    string rest(size_t from) {
      return t.length > from ? t[from .. $].join(" ") : "";
    }

    switch (all) {
    case "now", "immediately":
      return normalize(ScheduleFormat.time, "now", now);
    case "hourly", "every hour":
      return normalize(ScheduleFormat.cron, "@hourly", now);
    case "daily", "every day", "every midnight":
      return normalize(ScheduleFormat.cron, "@daily", now);
    case "weekly", "every week":
      return normalize(ScheduleFormat.cron, "@weekly", now);
    case "monthly", "every month":
      return normalize(ScheduleFormat.cron, "@monthly", now);
    case "every minute":
      return normalize(ScheduleFormat.repeatInterval, "1 minute", now);
    case "every second":
      return normalize(ScheduleFormat.repeatInterval, "1 second", now);
    default:
      break;
    }
    if (t.length >= 2 && t[0] == "in") // in 5 minutes
      return normalize(ScheduleFormat.time, isoTimeText(plusSeconds(now, parseInterval(rest(1)))), now);
    if (t.length >= 2 && t[0] == "at") // at 2026-12-01T10:00:00Z
      return normalize(ScheduleFormat.time, rest(1), now);
    if (t.length >= 3 && (t[0] == "daily" || (t[0] == "every" && t[1] == "day")) && t.canFind("at")) {
      auto at = t.countUntil("at");
      return normalize(ScheduleFormat.repeatAt, rest(at + 1), now);
    }
    if (t.length >= 4 && t[0] == "every" && t[2] == "at") {
      auto sod = parseTimeOfDay(rest(3));
      string dow;
      auto day = t[1].endsWith("s") && t[1] != "weekdays" ? t[1][0 .. $ - 1] : t[1];
      if (day == "weekday" || day == "weekdays")
        dow = "1-5";
      else if (day == "weekend")
        dow = "0,6";
      else {
        auto i = weekdayWords.countUntil(day);
        if (i < 0)
          i = weekdayWords.countUntil!(w => w[0 .. 3] == day);
        if (i < 0)
          throw JobSchedulingException.invalid("Unknown day '" ~ t[1] ~ "' in '" ~ text ~ "'");
        dow = i.to!string;
      }
      if (sod % 60 != 0)
        throw JobSchedulingException.invalid("Weekly schedules run on whole minutes ('" ~ text ~ "')");
      return normalize(ScheduleFormat.cron, format("%d %d * * %s", sod % 3600 / 60, sod / 3600, dow), now);
    }
    if (t.length >= 2 && t[0] == "every") // every 10 minutes, every 2h
      return normalize(ScheduleFormat.repeatInterval, rest(1), now);
    throw JobSchedulingException.invalid("Cannot understand the schedule '" ~ text ~ "' (examples: 'every 10 minutes', "
        ~ "'every day at 14:30', 'every monday at 8:00', 'every weekday at 7:30', 'hourly', 'in 5 minutes', 'now')");
  }

  /// The first run after `after` (std time), honoring the window
  /// [startTime, endTime] (0 = open). lastRunAt is the previous run
  /// (0 = none). 0 means: no further run.
  static long nextRun(ScheduleRule rule, long after, long lastRunAt, long startTime = 0, long endTime = 0) {
    long next;
    auto from = startTime > after ? startTime - 1 : after;
    final switch (rule.format) {
    case ScheduleFormat.cron:
      next = CronExpression.parse(rule.expression).next(from);
      break;
    case ScheduleFormat.repeatInterval:
      auto interval = parseInterval(rule.expression);
      if (lastRunAt == 0 && startTime > after)
        next = startTime;
      else {
        next = plusSeconds(lastRunAt > 0 ? lastRunAt : after, interval);
        if (next <= after) // missed runs (downtime): one catch-up, then the regular rhythm
          next = plusSeconds(after, interval);
      }
      break;
    case ScheduleFormat.repeatAt:
      auto sod = parseTimeOfDay(rule.expression);
      next = plusSeconds(startOfDay(from), sod);
      if (next <= from)
        next = plusDays(next, 1);
      break;
    case ScheduleFormat.time:
      next = lastRunAt > 0 ? 0 : parseIsoTime(rule.expression, "Time");
      break;
    case ScheduleFormat.humanReadable:
      throw JobSchedulingException.invalid("Human readable schedules must be normalized first");
    }
    if (next > 0 && endTime > 0 && next > endTime)
      return 0;
    return next;
  }

  /// The next n runs (preview).
  static long[] upcoming(ScheduleRule rule, long after, size_t n, long startTime = 0, long endTime = 0) {
    long[] runs;
    long last;
    auto at = after;
    foreach (_; 0 .. n) {
      auto next = nextRun(rule, at, last, startTime, endTime);
      if (next == 0)
        break;
      runs ~= next;
      last = next;
      at = next;
    }
    return runs;
  }

  /// "every 10 minutes", "daily at 14:30 UTC", "cron 0 2 * * * (UTC)", "once at …"
  static string describe(ScheduleRule rule) {
    final switch (rule.format) {
    case ScheduleFormat.cron:
      return "cron " ~ rule.expression ~ " (UTC)";
    case ScheduleFormat.repeatInterval:
      return "every " ~ rule.expression;
    case ScheduleFormat.repeatAt:
      return "daily at " ~ rule.expression ~ " UTC";
    case ScheduleFormat.time:
      return "once at " ~ rule.expression;
    case ScheduleFormat.humanReadable:
      return rule.expression;
    }
  }
}

///
unittest {
  auto now = parseIsoTime("2026-03-02T10:00:20Z"); // a Monday
  auto r(ScheduleFormat f, string e) => ScheduleCalculator.normalize(f, e, now);
  auto h(string e) => ScheduleCalculator.humanReadable(e, now);

  assert(h("every 10 minutes") == ScheduleRule(ScheduleFormat.repeatInterval, "10 minutes"));
  assert(h("Every day at 4.40pm") == ScheduleRule(ScheduleFormat.repeatAt, "16:40"));
  assert(h("daily at 7:05") == ScheduleRule(ScheduleFormat.repeatAt, "07:05"));
  assert(h("every monday at 8:00") == ScheduleRule(ScheduleFormat.cron, "0 8 * * 1"));
  assert(h("every fri at 17:30") == ScheduleRule(ScheduleFormat.cron, "30 17 * * 5"));
  assert(h("every weekday at 7:30") == ScheduleRule(ScheduleFormat.cron, "30 7 * * 1-5"));
  assert(h("hourly") == ScheduleRule(ScheduleFormat.cron, "0 * * * *"));
  assert(h("in 5 minutes") == ScheduleRule(ScheduleFormat.time, "2026-03-02T10:05:20Z"));
  assert(h("now").type == ScheduleType.oneTime && h("every 2h").type == ScheduleType.recurring);
  assert(failsWith(JsErrorKind.invalid, () { h("whenever you like"); }));
  assert(failsWith(JsErrorKind.invalid, () { h("every blursday at 8:00"); }));

  // next runs
  auto at(string s) => parseIsoTime(s);
  auto cron = r(ScheduleFormat.cron, "*/15 * * * *");
  assert(ScheduleCalculator.nextRun(cron, now, 0) == at("2026-03-02T10:15:00Z"));
  auto interval = r(ScheduleFormat.repeatInterval, "10min");
  assert(interval.expression == "10 minutes");
  assert(ScheduleCalculator.nextRun(interval, now, 0) == at("2026-03-02T10:10:20Z"));
  assert(ScheduleCalculator.nextRun(interval, now, at("2026-03-02T09:55:00Z")) == at("2026-03-02T10:05:00Z"));
  assert(ScheduleCalculator.nextRun(interval, now, at("2026-03-01T00:00:00Z")) == at("2026-03-02T10:10:20Z")); // catch-up
  auto daily = r(ScheduleFormat.repeatAt, "09:00");
  assert(ScheduleCalculator.nextRun(daily, now, 0) == at("2026-03-03T09:00:00Z"));
  auto once = r(ScheduleFormat.time, "2026-03-01T08:00:00Z");
  assert(ScheduleCalculator.nextRun(once, now, 0) == at("2026-03-01T08:00:00Z")); // past: due now
  assert(ScheduleCalculator.nextRun(once, now, at("2026-03-01T08:00:01Z")) == 0); // ran already

  // window
  auto start = at("2026-04-01T00:00:00Z");
  assert(ScheduleCalculator.nextRun(cron, now, 0, start) == start);
  assert(ScheduleCalculator.nextRun(interval, now, 0, start) == start);
  assert(ScheduleCalculator.nextRun(daily, now, 0, 0, at("2026-03-03T08:00:00Z")) == 0);

  auto preview = ScheduleCalculator.upcoming(cron, now, 3);
  assert(preview.length == 3 && isoTimeText(preview[2]) == "2026-03-02T10:45:00Z");
  assert(ScheduleCalculator.upcoming(once, now, 5).length == 1);
  assert(ScheduleCalculator.describe(daily) == "daily at 09:00 UTC");
}
