/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of workflows and their tasks.
module uim.platform.integration_automation.ports.usecases.workflows;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

interface IManageWorkflows {
  /// Instantiate a workflow from an active scenario (tasks included).
  Workflow create(CreateWorkflowCommand c);
  /// Change name and description.
  Workflow update(UpdateWorkflowCommand c);
  Workflow get(TenantId t, WorkflowId id);
  Workflow[] list(TenantId t);
  /// Planned or finished workflows only; removes the tasks, keeps the log.
  void remove(TenantId t, WorkflowId id, UserId actor);
  Workflow start(TenantId t, WorkflowId id, UserId actor);
  Workflow suspend(TenantId t, WorkflowId id, UserId actor);
  Workflow resume(TenantId t, WorkflowId id, UserId actor);
  Workflow terminate(TenantId t, WorkflowId id, string reason, UserId actor);
}

interface IProcessTasks {
  WorkflowTask get(TenantId t, WorkflowTaskId id);
  WorkflowTask[] list(TenantId t);
  WorkflowTask[] listOf(TenantId t, WorkflowId workflow);
  WorkflowTask start(TenantId t, WorkflowTaskId id, UserId actor);
  WorkflowTask complete(TenantId t, WorkflowTaskId id, string result, UserId actor);
  WorkflowTask fail(TenantId t, WorkflowTaskId id, string errorMessage, UserId actor);
  WorkflowTask skip(TenantId t, WorkflowTaskId id, string reason, UserId actor);
  WorkflowTask retry(TenantId t, WorkflowTaskId id, UserId actor);
  /// Assign to a user ("" = unassign) and/or change the priority ("" = keep).
  WorkflowTask assign(TenantId t, WorkflowTaskId id, string assignedTo, string priority, UserId actor);
  /// Execute every ready automated and notification task of the running
  /// workflows (one workflow if given), following their dependencies.
  AutomationRunSummary runAutomation(TenantId t, UserId actor, WorkflowId only = WorkflowId.init);
}
