/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Scheduling rules of application jobs.
module uim.platform.abap_environment.domain.services.job_schedule;

import std.ascii : isDigit;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

enum long stdTimeHour = 36_000_000_000L;

/// Maximum number of runs kept in a job's execution history.
enum size_t maxExecutionHistory = 20;

/// The start after `from` for a recurring job (0 for `once`).
/// Months are approximated as 30 days.
long nextRun(JobFrequency frequency, long from) pure nothrow {
  final switch (frequency) {
  case JobFrequency.once:
    return 0;
  case JobFrequency.hourly:
    return from + stdTimeHour;
  case JobFrequency.daily:
    return from + 24 * stdTimeHour;
  case JobFrequency.weekly:
    return from + 7 * 24 * stdTimeHour;
  case JobFrequency.monthly:
    return from + 30 * 24 * stdTimeHour;
  }
}

/// A five field cron expression: minute hour day-of-month month day-of-week.
/// Each field is "*", a number, a range "a-b", a step "*/n" or a list "a,b".
void validateCron(string expression) {
  auto e = expression.strip;
  if (e.length == 0)
    return;
  auto fields = e.split!(c => c == ' ').filter!(f => f.length > 0).array;
  validate(fields.length == 5, "Cron expression needs 5 fields (minute hour day month weekday), got "
      ~ fields.length.to!string);
  static immutable int[2][5] ranges = [[0, 59], [0, 23], [1, 31], [1, 12], [0, 7]];
  static immutable string[5] names = ["minute", "hour", "day", "month", "weekday"];

  void number(string text, size_t field) {
    validate(text.length > 0 && text.all!(c => isDigit(c)), "Cron " ~ names[field] ~ " '" ~ text ~ "' is not a number");
    auto v = text.to!int;
    validate(v >= ranges[field][0] && v <= ranges[field][1], "Cron " ~ names[field] ~ " "
        ~ text ~ " is out of range " ~ ranges[field][0].to!string ~ "–" ~ ranges[field][1].to!string);
  }

  foreach (i, f; fields) {
    foreach (part; f.split(",")) {
      auto stepAt = part.indexOf('/');
      auto base = stepAt >= 0 ? part[0 .. stepAt] : part;
      if (stepAt >= 0)
        validate(part[stepAt + 1 .. $].length > 0 && part[stepAt + 1 .. $].all!(c => isDigit(c))
            && part[stepAt + 1 .. $].to!int > 0, "Cron step in '" ~ part ~ "' must be a positive number");
      if (base == "*")
        continue;
      auto dash = base.indexOf('-');
      if (dash > 0) {
        number(base[0 .. dash], i);
        number(base[dash + 1 .. $], i);
        validate(base[0 .. dash].to!int <= base[dash + 1 .. $].to!int, "Cron range '" ~ base ~ "' is reversed");
      } else
        number(base, i);
    }
  }
}

/// Append a run to the history, keeping at most `maxExecutionHistory` entries.
void recordRun(ref ApplicationJob job, JobExecutionLog run) {
  job.executionHistory ~= run;
  if (job.executionHistory.length > maxExecutionHistory)
    job.executionHistory = job.executionHistory[$ - maxExecutionHistory .. $];
}

///
unittest {
  assert(nextRun(JobFrequency.once, 100) == 0);
  assert(nextRun(JobFrequency.daily, 0) == 24 * stdTimeHour);
  validateCron("");
  validateCron("0 2 * * 1-5");
  validateCron("*/15 0,12 1 */2 0");
  bool failed(string e) {
    try
      validateCron(e);
    catch (AbapValidationException)
      return true;
    return false;
  }

  assert(failed("0 2 * *"));
  assert(failed("60 2 * * *"));
  assert(failed("0 5-2 * * *"));
  assert(failed("*/0 * * * *"));
  assert(failed("a * * * *"));

  ApplicationJob job;
  foreach (i; 0 .. 25)
    recordRun(job, JobExecutionLog("r" ~ i.to!string));
  assert(job.executionHistory.length == maxExecutionHistory && job.executionHistory[$ - 1].runId == "r24");
}
