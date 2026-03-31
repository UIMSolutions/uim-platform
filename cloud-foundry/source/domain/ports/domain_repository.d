module domain.ports.domain_repository;

import domain.types;
import domain.entities.cf_domain;

/// Port for persisting and querying Cloud Foundry domains.
interface DomainRepository
{
  CfDomain[] findByOrg(OrgId orgId, TenantId tenantId);
  CfDomain* findById(DomainId id, TenantId tenantId);
  CfDomain* findByName(TenantId tenantId, string name);
  CfDomain[] findShared(TenantId tenantId);
  CfDomain[] findByTenant(TenantId tenantId);
  void save(CfDomain domain);
  void update(CfDomain domain);
  void remove(DomainId id, TenantId tenantId);
}
