/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.entities.workflow;

// import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
/// A workflow instance — a running execution of an integration scenario
/// for a specific tenant. Contains the current execution progress.
struct Workflow {
  mixin(TenantEntity!WorkflowId);

  ScenarioId scenarioId;
  string name;
  string description;
  WorkflowStatus status = WorkflowStatus.planned;
  int currentStepIndex; // 0-based index of current step
  int totalSteps;
  int completedSteps;
  SystemConnectionId sourceSystemConnectionId; // selected source system
  SystemConnectionId targetSystemConnectionId; // selected target system
  long startedAt;

  Json toJson() const {
    return entityToJson()
      .set("scenarioId", scenarioId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("currentStepIndex", currentStepIndex)
      .set("totalSteps", totalSteps)
      .set("completedSteps", completedSteps)
      .set("sourceSystemConnectionId", sourceSystemConnectionId.value)
      .set("targetSystemConnectionId", targetSystemConnectionId.value)
      .set("startedAt", startedAt);
  }
}
