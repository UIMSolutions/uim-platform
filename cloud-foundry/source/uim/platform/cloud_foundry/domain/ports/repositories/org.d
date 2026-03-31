module uim.platform.cloud_foundry.domain.ports.org;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.organization;

/// Port for persisting and querying organizations.
interface OrgRepository {
  Organization[] findByTenant(TenantId tenantId);
  Organization* findById(OrgId id, TenantId tenantId);
  Organization* findByName(TenantId tenantId, string name);
  void save(Organization org);
  void update(Organization org);
  void remove(OrgId id, TenantId tenantId);
}
