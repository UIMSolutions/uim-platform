module uim.platform.foundry.domain.ports.space;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.space;

/// Port for persisting and querying spaces.
interface SpaceRepository {
  Space[] findByOrg(OrgId orgId, TenantId tenantId);
  Space* findById(SpaceId id, TenantId tenantId);
  Space* findByName(OrgId orgId, TenantId tenantId, string name);
  Space[] findByTenant(TenantId tenantId);
  void save(Space space);
  void update(Space space);
  void remove(SpaceId id, TenantId tenantId);
  void removeByOrg(OrgId orgId, TenantId tenantId);
}
