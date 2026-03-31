module domain.ports.scenario_repository;

import domain.types;
import domain.entities.integration_scenario;

/// Port for persisting and querying integration scenarios.
interface ScenarioRepository
{
  IntegrationScenario[] findByTenant(TenantId tenantId);
  IntegrationScenario* findById(ScenarioId id, TenantId tenantId);
  IntegrationScenario[] findByCategory(TenantId tenantId, ScenarioCategory category);
  IntegrationScenario[] findByStatus(TenantId tenantId, ScenarioStatus status);
  IntegrationScenario[] findBySystemType(TenantId tenantId, SystemType systemType);
  void save(IntegrationScenario scenario);
  void update(IntegrationScenario scenario);
  void remove(ScenarioId id, TenantId tenantId);
}
