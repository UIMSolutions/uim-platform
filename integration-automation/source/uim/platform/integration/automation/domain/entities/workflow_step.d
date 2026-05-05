/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.entities.workflow_step;

// import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
/// An individual step / task within a workflow instance.
/// Can be manual (requires user action) or automated (executed via API).
struct WorkflowStep {
  mixin TenantEntity!StepId;

  WorkflowId workflowId;
  string name;
  string description;
  StepType type_;
  StepStatus status = StepStatus.pending;
  StepPriority priority = StepPriority.medium;
  int sequenceNumber;
  string assignedTo; // userId of assigned person
  string assignedRole; // role required for the task
  string instructions; // detailed step-by-step instructions
  string automationEndpoint; // endpoint for automated execution
  string automationPayload; // payload for automated execution
  SystemConnectionId sourceSystemConnectionId;
  SystemConnectionId targetSystemConnectionId;
  StepId[] dependencies; // IDs of steps that must complete first
  string result; // outcome details / response
  string errorMessage;
  long startedAt;
  long completedAt;
  int estimatedDurationMinutes;

  Json toJson() const {
    return entityToJson
      .set("workflowId", workflowId)
      .set("name", name)
      .set("description", description)
      .set("type_", type_.to!string())
      .set("status", status.to!string())
      .set("priority", priority.to!string())
      .set("sequenceNumber", sequenceNumber)
      .set("assignedTo", assignedTo)
      .set("assignedRole", assignedRole)
      .set("instructions", instructions)
      .set("automationEndpoint", automationEndpoint)
      .set("automationPayload", automationPayload)
      .set("sourceSystemConnectionId", sourceSystemConnectionId)
      .set("targetSystemConnectionId", targetSystemConnectionId)
      .set("dependencies", dependencies)
      .set("result", result)
      .set("errorMessage", errorMessage)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("estimatedDurationMinutes", estimatedDurationMinutes);
  }
}
