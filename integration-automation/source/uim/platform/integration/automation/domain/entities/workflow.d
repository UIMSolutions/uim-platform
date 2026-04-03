/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.entities.workflow;

import uim.platform.integration.automation.domain.types;

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
  int currentStepIndex; // 0-based index of current step
  int totalSteps;
  int completedSteps;
  SystemId sourceSystemId; // selected source system
  SystemId targetSystemId; // selected target system
  string createdBy;
  long startedAt;
  long completedAt;
  long createdAt;
  long updatedAt;
}
