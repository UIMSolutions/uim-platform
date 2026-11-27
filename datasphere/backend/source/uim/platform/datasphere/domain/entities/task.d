/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A task runs one object of the space — a remote table snapshot, a data
/// flow or a view persistence — on demand or on a schedule, with retries.
module uim.platform.datasphere.domain.entities.task;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum int maxTaskRetries = 10;

/// The kind of run a task type produces.
RunObjectType runObjectOf(TaskType t) pure {
  final switch (t) {
  case TaskType.replication:
    return RunObjectType.replication;
  case TaskType.dataFlow:
    return RunObjectType.dataFlow;
  case TaskType.viewPersistence:
    return RunObjectType.viewPersistence;
  }
}

struct DataTask {
  mixin TenantEntity!TaskId;

  SpaceId spaceId;
  string name;
  string description;
  TaskType taskType = TaskType.replication;
  string targetObjectId; /// remote table, data flow or view id
  ScheduleFrequency frequency = ScheduleFrequency.manual;
  int intervalMinutes; /// frequency "interval"
  long startAt; /// first firing (std time); 0 = from creation
  ScheduleStatus status = ScheduleStatus.active;
  int maxRetries; /// additional attempts of a failed run
  long nextRunAt; /// 0 = not scheduled
  RunStatus lastRunStatus = RunStatus.notRun;
  long lastRunAt;
  long lastRunDurationMs;
  string lastRunMessage;
  int consecutiveFailures;

  bool isScheduled() const {
    return status == ScheduleStatus.active && frequency != ScheduleFrequency.manual;
  }

  /// True if the schedule fires at the given time.
  bool isDue(long at) const {
    return isScheduled && nextRunAt > 0 && nextRunAt <= at;
  }

  /// Plan the next firing after `after`.
  void reschedule(long after) {
    nextRunAt = isScheduled ? nextRunAfter(frequency, intervalMinutes, startAt, after) : 0;
  }

  /// Record the outcome of a run.
  void recordRun(RunStatus result, long at, long durationMs, string message) {
    lastRunStatus = result;
    lastRunAt = at;
    lastRunDurationMs = durationMs;
    lastRunMessage = message;
    consecutiveFailures = result == RunStatus.failed ? consecutiveFailures + 1 : 0;
  }

  void validate() const {
    requireId(id.value, "Task ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the task is required");
    requireText(name, "Task name");
    requireMaxLength(name, 200, "Task name");
    requireMaxLength(description, 2000, "Description");
    requireId(targetObjectId, "Target object");
    validateSchedule(frequency, intervalMinutes);
    requireRange(maxRetries, 0, maxTaskRetries, "Retries");
  }
}

///
unittest {
  DataTask t;
  t.id = TaskId("t");
  t.spaceId = SpaceId("SALES");
  t.name = "Replicate orders";
  t.targetObjectId = "orders";
  t.validate();
  auto at = parseIsoTime("2026-02-01T10:00:00Z");
  t.reschedule(at);
  assert(!t.isScheduled && t.nextRunAt == 0 && !t.isDue(at));
  t.frequency = ScheduleFrequency.hourly;
  t.reschedule(at);
  assert(t.isDue(plusSeconds(at, 3600)) && !t.isDue(at));
  t.status = ScheduleStatus.paused;
  assert(!t.isDue(plusSeconds(at, 3600)));
  t.recordRun(RunStatus.failed, at, 5, "boom");
  t.recordRun(RunStatus.failed, at, 5, "boom");
  assert(t.consecutiveFailures == 2);
  t.recordRun(RunStatus.completed, at, 5, "");
  assert(t.consecutiveFailures == 0 && runObjectOf(TaskType.dataFlow) == RunObjectType.dataFlow);
}
