/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.entities.application_job;

import uim.platform.abap_enviroment.domain.types;

/// Execution log entry for a job run.
struct JobExecutionLog {
  string executionId;
  JobStatus status;
  long startedAt;
  long finishedAt;
  string message;
  int returnCode;
}

/// Application job definition and schedule.
struct ApplicationJob {
  ApplicationJobId id;
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string jobTemplateName;

  /// Scheduling
  JobFrequency frequency = JobFrequency.once;
  long scheduledAt;
  string cronExpression;
  bool active = true;

  /// Current run status
  JobStatus status = JobStatus.scheduled;
  JobExecutionLog[] executionHistory;

  /// Parameters
  string[string] jobParameters;

  /// Metadata
  string createdBy;
  long createdAt;
  long updatedAt;
}
