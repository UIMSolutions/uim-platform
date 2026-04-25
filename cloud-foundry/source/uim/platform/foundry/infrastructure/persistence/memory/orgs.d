/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.orgs;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.organization;
// import uim.platform.foundry.domain.ports.repositories.org;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryOrgRepository : TenantRepository!(Organization, OrgId), IOrgRepository {
  
  bool existsByName(TenantId tenantId, string name) {
    return !findByName(tenantId, name).isNull;
  }

  Organization findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return Organization.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
         return remove(e);
  }
  
}
