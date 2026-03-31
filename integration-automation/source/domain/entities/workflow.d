module domain.entities.workflow;

import domain.types;

/// A workflow instance — a running execution of an integration scenario
/// for a specific tenant. Contains the current execution progress.
struct Workflow
{
  WorkflowId id;
  TenantId tenantId;
  ScenarioId scenarioId;
  string name;
  string description;
  WorkflowStatus status = WorkflowStatus.planned;
  int currentStepIndex;           // 0-based index of current step
  int totalSteps;
  int completedSteps;
  SystemId sourceSystemId;        // selected source system
  SystemId targetSystemId;        // selected target system
  string createdBy;
  long startedAt;
  long completedAt;
  long createdAt;
  long updatedAt;
}
