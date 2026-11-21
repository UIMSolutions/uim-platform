/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An execution schedule starts executions of a workflow configuration
/// periodically (5 field cron expression, UTC) within an optional window.
module uim.platform.ai_core.domain.entities.schedule;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct ExecutionSchedule {
  mixin TenantEntity!ScheduleId;

  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  string name;
  string cron;
  ScheduleStatus status = ScheduleStatus.active;
  long startTime; /// 0 = immediately
  long endTime; /// 0 = open end
  long lastRunAt;
  long nextRunAt;
  ExecutionId lastExecutionId;

  bool isActive() const {
    return status == ScheduleStatus.active;
  }

  /// True if the schedule may fire at the given time.
  bool inWindow(long at) const {
    return (startTime == 0 || at >= startTime) && (endTime == 0 || at <= endTime);
  }

  void validate() const {
    requireText(name, "Schedule name");
    requireText(configurationId.value, "Configuration ID");
    CronExpression.parse(cron); // throws invalid
    if (startTime > 0 && endTime > 0 && endTime <= startTime)
      throw AiCoreException.invalid("Schedule end must be after its start");
  }
}
