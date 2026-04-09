/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.execution_log;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.execution_log;

/// Port for persisting and querying execution logs.
interface ExecutionLogRepository {
  ExecutionLog[] findByWorkflow(WorkflowId workflowtenantId, id tenantId);
  ExecutionLog[] findByStep(StepId steptenantId, id tenantId);
  ExecutionLog[] findByTenant(TenantId tenantId);
  ExecutionLog[] findByOutcome(TenantId tenantId, ExecutionOutcome outcome);
  ExecutionLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  size_t countByWorkflow(WorkflowId workflowtenantId, id tenantId);
  void save(ExecutionLog log);
  void removeByWorkflow(WorkflowId workflowtenantId, id tenantId);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
