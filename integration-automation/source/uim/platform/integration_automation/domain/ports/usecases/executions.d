/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.domain.ports.usecases.executions;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
interface MonitorExecutionsUseCase { 

  ExecutionLog[] getWorkflowLogs(TenantId tenantId, WorkflowId workflowId);

  ExecutionLog[] getStepLogs(TenantId tenantId, WorkflowStepId stepId);

  ExecutionLog[] getAllLogs(TenantId tenantId);

  ExecutionLog[] getFailures(TenantId tenantId);

  ExecutionLog[] getLogsByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

  /// Get a workflow status summary suitable for a monitoring dashboard.
  WorkflowSummary getWorkflowSummary(TenantId tenantId, WorkflowId workflowId);

}
