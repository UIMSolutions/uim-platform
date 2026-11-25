/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An entry of the execution log: what happened to a workflow or task,
/// when, by whom, with which outcome (monitoring, audit, troubleshooting).
module uim.platform.integration_automation.domain.entities.execution_log;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct ExecutionLog {
  mixin TenantEntity!ExecutionLogId;

  WorkflowId workflowId;
  WorkflowTaskId taskId;
  string action; /// e.g. "workflow.started", "task.completed", "automation.failed"
  ExecutionOutcome outcome = ExecutionOutcome.info;
  string message;
  string details; /// extended information (HTTP status, response excerpt, …)
  string executedBy; /// user id, "automation" or "system"
  long durationMs;
}
