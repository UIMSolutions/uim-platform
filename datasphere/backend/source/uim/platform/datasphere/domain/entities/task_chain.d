/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A task chain runs tasks of the space one after another, on demand or on
/// a schedule. On a failed step the chain stops (later steps are
/// cancelled) or continues, depending on the failure policy.
module uim.platform.datasphere.domain.entities.task_chain;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum size_t maxChainSteps = 50;

struct TaskChain {
  mixin TenantEntity!TaskChainId;

  SpaceId spaceId;
  string name;
  string description;
  string[] taskIds; /// the steps, in order
  FailurePolicy failurePolicy = FailurePolicy.stop;
  ScheduleFrequency frequency = ScheduleFrequency.manual;
  int intervalMinutes;
  long startAt;
  ScheduleStatus status = ScheduleStatus.active;
  long nextRunAt;
  RunStatus lastRunStatus = RunStatus.notRun;
  long lastRunAt;
  long lastRunDurationMs;
  string lastRunMessage;

  bool isScheduled() const {
    return status == ScheduleStatus.active && frequency != ScheduleFrequency.manual;
  }

  bool isDue(long at) const {
    return isScheduled && nextRunAt > 0 && nextRunAt <= at;
  }

  void reschedule(long after) {
    nextRunAt = isScheduled ? nextRunAfter(frequency, intervalMinutes, startAt, after) : 0;
  }

  void validate() const {
    requireId(id.value, "Task chain ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the task chain is required");
    requireText(name, "Task chain name");
    requireMaxLength(name, 200, "Task chain name");
    requireMaxLength(description, 2000, "Description");
    if (taskIds.length > maxChainSteps)
      throw DspException.invalid(format("A task chain has at most %d steps", maxChainSteps));
    bool[string] seen;
    foreach (t; taskIds) {
      requireId(t, "Task");
      if (t in seen)
        throw DspException.invalid("Task '" ~ t ~ "' is a step of the chain twice");
      seen[t] = true;
    }
    validateSchedule(frequency, intervalMinutes);
  }
}

///
unittest {
  TaskChain c;
  c.id = TaskChainId("nightly");
  c.spaceId = SpaceId("SALES");
  c.name = "Nightly load";
  c.taskIds = ["replicate", "flow"];
  c.validate();
  c.taskIds ~= "flow";
  assert(failsWith(DspErrorKind.invalid, () { c.validate(); }));
}
