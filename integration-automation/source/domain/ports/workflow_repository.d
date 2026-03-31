module domain.ports.workflow_repository;

import domain.types;
import domain.entities.workflow;

/// Port for persisting and querying workflow instances.
interface WorkflowRepository
{
  Workflow[] findByTenant(TenantId tenantId);
  Workflow* findById(WorkflowId id, TenantId tenantId);
  Workflow[] findByScenario(TenantId tenantId, ScenarioId scenarioId);
  Workflow[] findByStatus(TenantId tenantId, WorkflowStatus status);
  Workflow[] findByCreator(TenantId tenantId, UserId createdBy);
  long countByTenant(TenantId tenantId);
  long countActiveByTenant(TenantId tenantId);
  void save(Workflow workflow);
  void update(Workflow workflow);
  void remove(WorkflowId id, TenantId tenantId);
}
