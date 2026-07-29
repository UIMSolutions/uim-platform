/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.domain.ports.repositories.execution_log;

// import uim.platform.integration_automation.domain.entities.execution_log;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying execution logs.
interface IExecutionLogRepository : ITenantRepository!(ExecutionLog, ExecutionLogId) {

  size_t countByWorkflow(TenantId tenantId, WorkflowId workflowId);
  ExecutionLog[] findByWorkflow(TenantId tenantId, WorkflowId workflowId);
  void removeByWorkflow(TenantId tenantId, WorkflowId workflowId);

  size_t countByStep(TenantId tenantId, WorkflowStepId stepId);
  ExecutionLog[] findByStep(TenantId tenantId, WorkflowStepId stepId);
  void removeByStep(TenantId tenantId, WorkflowStepId stepId);

  size_t countByOutcome(TenantId tenantId, ExecutionOutcome outcome);
  ExecutionLog[] findByOutcome(TenantId tenantId, ExecutionOutcome outcome);
  void removeByOutcome(TenantId tenantId, ExecutionOutcome outcome);

  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  ExecutionLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

}
