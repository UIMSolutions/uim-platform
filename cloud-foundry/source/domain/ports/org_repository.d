module domain.ports.org_repository;

import domain.types;
import domain.entities.organization;

/// Port for persisting and querying organizations.
interface OrgRepository
{
  Organization[] findByTenant(TenantId tenantId);
  Organization* findById(OrgId id, TenantId tenantId);
  Organization* findByName(TenantId tenantId, string name);
  void save(Organization org);
  void update(Organization org);
  void remove(OrgId id, TenantId tenantId);
}
