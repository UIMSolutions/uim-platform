/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.entities.workflow_step;

import uim.platform.integration.automation.domain.types;

/// An individual step / task within a workflow instance.
/// Can be manual (requires user action) or automated (executed via API).
struct WorkflowStep
{
  StepId id;
  WorkflowId workflowId;
  TenantId tenantId;
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
  SystemId sourceSystemId;
  SystemId targetSystemId;
  StepId[] dependencies; // IDs of steps that must complete first
  string result; // outcome details / response
  string errorMessage;
  long startedAt;
  long completedAt;
  long createdAt;
  int estimatedDurationMinutes;
}
