module uim.platform.xyz.domain.ports.repositories.execution_log;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.execution_log;

/// Port for persisting and querying execution logs.
interface ExecutionLogRepository
{
  ExecutionLog[] findByWorkflow(WorkflowId workflowId, TenantId tenantId);
  ExecutionLog[] findByStep(StepId stepId, TenantId tenantId);
  ExecutionLog[] findByTenant(TenantId tenantId);
  ExecutionLog[] findByOutcome(TenantId tenantId, ExecutionOutcome outcome);
  ExecutionLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  long countByWorkflow(WorkflowId workflowId, TenantId tenantId);
  void save(ExecutionLog log);
  void removeByWorkflow(WorkflowId workflowId, TenantId tenantId);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
