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

  // #region ByName
  bool existsByName(TenantId tenantId, string name) {
    return !findByName(tenantId, name).isNull;
  }

  CfDomain findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return CfDomain.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return remove(e);
  }
  // #endregion ByName

  // #region ByOrg
  size_t countByOrg(TenantId tenantId, OrgId orgId) {
    return findByOrg(tenantId, orgId).length;
  }

  CfDomain[] filterByOrg(CfDomain[] domains, OrgId orgId) {
    return domains.filter!(e => e.ownerOrgId == orgId).array;
  }

  CfDomain[] findByOrg(TenantId tenantId, OrgId orgId) {
    return filterByOrg(findByTenant(tenantId), orgId);
  }

  void removeByOrg(TenantId tenantId, OrgId orgId) {
    findByOrg(tenantId, orgId).each!(e => remove(e));
  }
  // #endregion ByOrg

  // #region Shared
  size_t countShared(TenantId tenantId) {
    return findShared(tenantId).length;
  }

  CfDomain[] filterShared(CfDomain[] domains) {
    return domains.filter!(e => e.scope_ == DomainScope.shared_).array;
  }

  CfDomain[] findShared(TenantId tenantId) {
    return filterShared(findByTenant(tenantId));
  }

  void removeShared(TenantId tenantId) {
    findShared(tenantId).each!(e => remove(e));
  }
  // #endregion Shared
  
}
