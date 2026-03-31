module domain.ports.app_repository;

import domain.types;
import domain.entities.application;

/// Port for persisting and querying applications.
interface AppRepository
{
  Application[] findBySpace(SpaceId spaceId, TenantId tenantId);
  Application* findById(AppId id, TenantId tenantId);
  Application* findByName(SpaceId spaceId, TenantId tenantId, string name);
  Application[] findByState(SpaceId spaceId, TenantId tenantId, AppState state);
  Application[] findByTenant(TenantId tenantId);
  long countBySpace(SpaceId spaceId, TenantId tenantId);
  void save(Application app);
  void update(Application app);
  void remove(AppId id, TenantId tenantId);
}
