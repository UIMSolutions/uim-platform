/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.entities.execution_log;

// import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
/// An execution log entry — records the execution of a workflow step
/// for monitoring, auditing, and troubleshooting purposes.
struct ExecutionLog {
  mixin TenantEntity!ExecutionLogId;

  WorkflowId workflowId;
  StepId stepId;
  string action; // e.g. "step.started", "step.completed"
  ExecutionOutcome outcome;
  string message;
  string details; // extended info (JSON payload, error trace)
  UserId executedBy; // userId or "system"
  long durationMs; // execution duration in milliseconds
  long timestamp;

  Json toJson() const {
    return entityToJson
      .set("workflowId", workflowId)
      .set("stepId", stepId)
      .set("action", action)
      .set("outcome", outcome.to!string())
      .set("message", message)
      .set("details", details)
      .set("executedBy", executedBy)
      .set("durationMs", durationMs)
      .set("timestamp", timestamp);
  }
}
