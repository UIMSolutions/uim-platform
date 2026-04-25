/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.domain;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.cf_domain;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying Cloud Foundry domains.
interface IDomainRepository : ITenantRepository!(CfDomain, CfDomainId) {

  bool existsByName(TenantId tenantId, string name);
  CfDomain findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
  size_t countByOrg(TenantId tenantId, OrgId orgId);
  CfDomain[] filterByOrg(CfDomain[] domains, OrgId orgId);
  CfDomain[] findByOrg(TenantId tenantId, OrgId orgId);
  void removeByOrg(TenantId tenantId, OrgId orgId);
  
  size_t countShared(TenantId tenantId);
  CfDomain[] filterShared(CfDomain[] domains);
  CfDomain[] findShared(TenantId tenantId);
  void removeShared(TenantId tenantId);
  
}
