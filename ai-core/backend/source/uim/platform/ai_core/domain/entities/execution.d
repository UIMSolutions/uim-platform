/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An execution is one run of a workflow configuration (e.g. a training).
module uim.platform.ai_core.domain.entities.execution;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Execution {
  mixin TenantEntity!ExecutionId;

  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  ScheduleId scheduleId; /// set if triggered by a schedule
  ExecutionStatus status = ExecutionStatus.unknown;
  TargetStatus targetStatus = TargetStatus.completed;
  string statusMessage;
  long submissionTime;
  long startTime;
  long completionTime;
  ArtifactRef[] outputArtifacts;
  Label[] tags;

  /// Seconds the execution has been running (0 if it never started).
  long durationSeconds(long now) const {
    if (startTime == 0)
      return 0;
    return secondsBetween(startTime, completionTime > 0 ? completionTime : now);
  }
}
