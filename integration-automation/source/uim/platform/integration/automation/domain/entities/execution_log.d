module uim.platform.xyz.domain.entities.execution_log;

import uim.platform.xyz.domain.types;

/// An execution log entry — records the execution of a workflow step
/// for monitoring, auditing, and troubleshooting purposes.
struct ExecutionLog {
  ExecutionLogId id;
  WorkflowId workflowId;
  StepId stepId;
  TenantId tenantId;
  string action; // e.g. "step.started", "step.completed"
  ExecutionOutcome outcome;
  string message;
  string details; // extended info (JSON payload, error trace)
  string executedBy; // userId or "system"
  long durationMs; // execution duration in milliseconds
  long timestamp;
}
