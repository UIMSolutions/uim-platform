/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.application_job;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// An application job: a scheduled run of a job template with parameters.
struct ApplicationJob {
  mixin TenantEntity!ApplicationJobId;

  SystemInstanceId systemInstanceId;
  string systemName;
  string name;
  string description;
  string jobTemplateName; /// e.g. "SAP_CORE_DELETE_LOGS"

  JobFrequency frequency = JobFrequency.once;
  long scheduledAt; /// next planned start (0 = immediately)
  string cronExpression; /// validated and stored; the simulator schedules by frequency
  bool active = true;
  JobStatus status = JobStatus.scheduled;

  KeyValue[] parameters;
  JobExecutionLog[] executionHistory; /// newest last, capped
  int runCount;
  long lastRunAt;
}
