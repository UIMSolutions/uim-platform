module infrastructure.persistence.in_memory_workflow_repo;

import domain.types;
import domain.entities.workflow;
import domain.ports.workflow_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryWorkflowRepository : WorkflowRepository
{
  private Workflow[WorkflowId] store;

  Workflow[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Workflow* findById(WorkflowId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Workflow[] findByScenario(TenantId tenantId, ScenarioId scenarioId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.scenarioId == scenarioId)
      .array;
  }

  Workflow[] findByStatus(TenantId tenantId, WorkflowStatus status)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.status == status)
      .array;
  }

  Workflow[] findByCreator(TenantId tenantId, UserId createdBy)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.createdBy == createdBy)
      .array;
  }

  long countByTenant(TenantId tenantId)
  {
    return cast(long) findByTenant(tenantId).length;
  }

  long countActiveByTenant(TenantId tenantId)
  {
    return cast(long) store.byValue()
      .filter!(e => e.tenantId == tenantId
        && (e.status == WorkflowStatus.inProgress
          || e.status == WorkflowStatus.planned
          || e.status == WorkflowStatus.suspended))
      .array.length;
  }

  void save(Workflow workflow)
  {
    store[workflow.id] = workflow;
  }

  void update(Workflow workflow)
  {
    store[workflow.id] = workflow;
  }

  void remove(WorkflowId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
