/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.application.usecases.manage.steps;

// import uim.platform.integration_automation.domain.entities.workflow_step;
// import uim.platform.integration_automation.domain.ports.repositories.steps;
// import uim.platform.integration_automation.domain.services.step_executor;
// import uim.platform.integration_automation.domain.services.workflow_engine;


import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
interface IManageStepsUseCase { 

  WorkflowStep[] listSteps(TenantId tenantId, WorkflowId workflowId);

  WorkflowStep getStep(TenantId tenantId, WorkflowStepId stepId);

  WorkflowStep[] getMyTasks(TenantId tenantId, UserId userId);

  WorkflowStep[] getTasksByRole(TenantId tenantId, string role);

  /// Start a step (mark as in-progress).
  CommandResult startStep(TenantId tenantId, WorkflowStepId stepId, UserId userId);

  /// Complete a step and advance the workflow.
  CommandResult completeStep(CompleteStepRequest req);

  /// Mark a step as failed.
  CommandResult failStep(FailStepRequest req);

  /// Skip a step and advance the workflow.
  CommandResult skipStep(SkipStepRequest req);

  /// Assign a step to a user.
  CommandResult assignStep(AssignStepRequest req);
  
  }
