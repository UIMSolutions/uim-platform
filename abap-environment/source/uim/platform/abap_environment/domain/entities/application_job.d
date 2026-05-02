/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.application_job;

// import uim.platform.abap_environment.domain.types;

/// Execution log entry for a job run.
import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

/// Application job definition and schedule.
struct ApplicationJob {
  mixin TenantEntity!(ApplicationJobId);
  
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

  Json toJson() const {
    auto j = entityToJson
      .set("systemInstanceId", systemInstanceId)
      .set("name", name)
      .set("description", description)
      .set("jobTemplateName", jobTemplateName)
      .set("frequency", frequency.to!string)
      .set("scheduledAt", scheduledAt)
      .set("cronExpression", cronExpression)
      .set("active", active)
      .set("status", status.to!string);

    if (executionHistory.length > 0) {
      auto history = executionHistory.map!(e => e.toJson).array.toJson();
      j = j.set("executionHistory", history);
    }

    if (jobParameters.length > 0) {
      auto params = Json.emptyObject;
      foreach (k, v; jobParameters) {
        params[k] = Json(v);
      }
      j["jobParameters"] = params;
    }

    return j;
  }
}
