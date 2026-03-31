module infrastructure.persistence.in_memory_execution_log_repo;

import domain.types;
import domain.entities.execution_log;
import domain.ports.execution_log_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryExecutionLogRepository : ExecutionLogRepository
{
  private ExecutionLog[] store;

  ExecutionLog[] findByWorkflow(WorkflowId workflowId, TenantId tenantId)
  {
    return store.filter!(e => e.workflowId == workflowId && e.tenantId == tenantId).array;
  }

  ExecutionLog[] findByStep(StepId stepId, TenantId tenantId)
  {
    return store.filter!(e => e.stepId == stepId && e.tenantId == tenantId).array;
  }

  ExecutionLog[] findByTenant(TenantId tenantId)
  {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  ExecutionLog[] findByOutcome(TenantId tenantId, ExecutionOutcome outcome)
  {
    return store.filter!(e => e.tenantId == tenantId && e.outcome == outcome).array;
  }

  ExecutionLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo)
  {
    return store.filter!((e) {
      if (e.tenantId != tenantId) return false;
      if (timeFrom > 0 && e.timestamp < timeFrom) return false;
      if (timeTo > 0 && e.timestamp > timeTo) return false;
      return true;
    }).array;
  }

  long countByWorkflow(WorkflowId workflowId, TenantId tenantId)
  {
    return cast(long) findByWorkflow(workflowId, tenantId).length;
  }

  void save(ExecutionLog log)
  {
    store ~= log;
  }

  void removeByWorkflow(WorkflowId workflowId, TenantId tenantId)
  {
    store = store.filter!(e => !(e.workflowId == workflowId && e.tenantId == tenantId)).array;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp)
  {
    store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
  }
}
