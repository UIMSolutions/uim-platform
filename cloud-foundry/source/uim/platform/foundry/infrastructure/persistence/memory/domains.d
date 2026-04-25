/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.domains;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.cf_domain;
// import uim.platform.foundry.domain.ports.repositories.domain;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryDomainRepository : TenantRepository!(CfDomain, CfDomainId), IDomainRepository {

  size_t countByOrg(TenantId tenantId, OrgId orgId) {
    return findByOrg(tenantId, orgId).length;
  }
  CfDomain[] findByOrg(TenantId tenantId, OrgId orgId) {
    return findByTenant(tenantId).filter!(e => e.ownerOrgId == orgId).array;
  }
  void removeByOrg(TenantId tenantId, OrgId orgId) {
    findByOrg(tenantId, orgId).each!(e => remove(e));
  }

  size_t countShared(TenantId tenantId) {
    return findShared(tenantId).length;
  }
  CfDomain[] findShared(TenantId tenantId) {
    return findByTenant(tenantId).filter!(e => e.scope_ == DomainScope.shared_).array;
  }
  void removeShared(TenantId tenantId) {
    findShared(tenantId).each!(e => remove(e.id));
  }

}
