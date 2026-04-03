module uim.platform.foundry.domain.ports.org;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.organization;

/// Port for persisting and querying organizations.
interface IOrgRepository {
  Organization[] findByTenant(TenantId tenantId);
  Organization* findById(OrgId id, TenantId tenantId);
  Organization* findByName(TenantId tenantId, string name);
  void save(Organization org);
  void update(Organization org);
  void remove(OrgId id, TenantId tenantId);
}
