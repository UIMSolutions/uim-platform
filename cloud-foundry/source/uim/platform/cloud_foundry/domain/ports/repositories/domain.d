module uim.platform.cloud_foundry.domain.ports.domain;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.cf_domain;

/// Port for persisting and querying Cloud Foundry domains.
interface DomainRepository {
  CfDomain[] findByOrg(OrgId orgId, TenantId tenantId);
  CfDomain* findById(DomainId id, TenantId tenantId);
  CfDomain* findByName(TenantId tenantId, string name);
  CfDomain[] findShared(TenantId tenantId);
  CfDomain[] findByTenant(TenantId tenantId);
  void save(CfDomain domain);
  void update(CfDomain domain);
  void remove(DomainId id, TenantId tenantId);
}
