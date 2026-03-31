module uim.platform.cloud_foundry.domain.ports.app;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.application;

/// Port for persisting and querying applications.
interface IAppRepository {
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
