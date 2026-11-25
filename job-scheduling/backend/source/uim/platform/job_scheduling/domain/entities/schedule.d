/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A schedule of a job: when the job runs (format + expression, see
/// ScheduleCalculator) and what it sends (data, a JSON document). The
/// scheduler keeps nextRunAt up to date; one-time schedules deactivate
/// themselves after their run.
module uim.platform.job_scheduling.domain.entities.schedule;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

enum size_t maxScheduleDataLength = 64 * 1024;

struct Schedule {
  mixin TenantEntity!ScheduleId;

  JobId jobId;
  string description;
  ScheduleFormat format = ScheduleFormat.cron;
  string expression; /// canonical (normalized) expression
  string data; /// JSON payload sent to the action endpoint ("" = none)
  bool active = true;
  long startTime; /// std time, 0 = open
  long endTime; /// std time, 0 = open
  long nextRunAt; /// 0 = no further run
  long lastRunAt;
  long runCount;

  ScheduleRule rule() const {
    return ScheduleRule(format, expression);
  }

  ScheduleType type() const {
    return rule.type;
  }

  /// Compute the next run after `after` (inactive: none).
  void plan(long after) {
    nextRunAt = active ? ScheduleCalculator.nextRun(rule, after, lastRunAt, startTime, endTime) : 0;
  }

  bool isDue(long now) const {
    return active && nextRunAt > 0 && nextRunAt <= now;
  }

  /// The schedule fired at `at`: count it and plan the next run; one-time
  /// schedules (and recurring ones past their end) deactivate.
  void fired(long at) {
    lastRunAt = at;
    runCount++;
    if (type == ScheduleType.oneTime) {
      active = false;
      nextRunAt = 0;
      return;
    }
    plan(at);
    if (nextRunAt == 0)
      active = false;
  }

  void validate() const @trusted {
    requireId(id.value, "Schedule ID");
    if (jobId.isNull)
      throw JobSchedulingException.invalid("The job of a schedule is required");
    requireMaxLength(description, 2000, "Description");
    if (format == ScheduleFormat.humanReadable)
      throw JobSchedulingException.invalid("Human readable schedules must be converted before they are stored");
    requireText(expression, "Schedule expression");
    if (startTime > 0 && endTime > 0 && endTime <= startTime)
      throw JobSchedulingException.invalid("The end time of a schedule must be after its start time");
    requireMaxLength(data, maxScheduleDataLength, "Data");
    if (data.strip.length) {
      Json j;
      try
        j = parseJsonString(data);
      catch (Exception e)
        throw JobSchedulingException.invalid("Data must be a JSON document: " ~ e.msg);
      if (j.type != Json.Type.object && j.type != Json.Type.array)
        throw JobSchedulingException.invalid("Data must be a JSON object or array");
    }
  }
}

///
unittest {
  auto now = parseIsoTime("2026-03-02T10:00:00Z");
  Schedule s;
  s.id = ScheduleId("s1");
  s.jobId = JobId("j1");
  s.format = ScheduleFormat.repeatInterval;
  s.expression = "5 minutes";
  s.data = `{"full": true}`;
  s.validate();
  s.plan(now);
  assert(s.nextRunAt == plusSeconds(now, 300) && !s.isDue(now) && s.isDue(plusSeconds(now, 300)));
  s.fired(plusSeconds(now, 301));
  assert(s.runCount == 1 && s.nextRunAt == plusSeconds(now, 601) && s.active);

  Schedule once = s;
  once.format = ScheduleFormat.time;
  once.expression = isoTimeText(now);
  once.lastRunAt = 0;
  once.plan(now);
  assert(once.isDue(now) && once.type == ScheduleType.oneTime);
  once.fired(now);
  assert(!once.active && once.nextRunAt == 0);

  s.data = "42";
  assert(failsWith(JsErrorKind.invalid, () { s.validate(); }));
  s.data = "{broken";
  assert(failsWith(JsErrorKind.invalid, () { s.validate(); }));
  s.data = "";
  s.format = ScheduleFormat.humanReadable;
  assert(failsWith(JsErrorKind.invalid, () { s.validate(); }));
}
