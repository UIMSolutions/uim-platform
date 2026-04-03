module uim.platform.xyz.domain.entities.integration_scenario;

import domain.types;

/// An integration scenario template — defines a reusable set of steps
/// for integrating SAP cloud solutions with on-premise or other cloud systems.
struct IntegrationScenario {
  ScenarioId id;
  TenantId tenantId;
  string name; // e.g. "SAP S/4HANA Cloud Integration"
  string description;
  ScenarioCategory category;
  string version_ = "1.0";
  ScenarioStatus status = ScenarioStatus.draft;
  SystemType sourceSystemType;
  SystemType targetSystemType;
  string[] prerequisites; // prerequisite descriptions
  ScenarioStepTemplate[] stepTemplates; // ordered step definitions
  string createdBy;
  long createdAt;
  long updatedAt;
}

/// Template for a step within a scenario — used to instantiate WorkflowSteps.
struct ScenarioStepTemplate {
  string name;
  string description;
  StepType type_;
  StepPriority priority = StepPriority.medium;
  int sequenceNumber;
  string assignedRole; // role responsible for the task
  string instructions; // detailed task instructions
  string automationEndpoint; // API endpoint for automated steps
  string automationPayload; // payload template for automation
  bool requiresSourceSystem;
  bool requiresTargetSystem;
  int[] dependsOnSteps; // sequence numbers of prerequisite steps
  int estimatedDurationMinutes;
}
