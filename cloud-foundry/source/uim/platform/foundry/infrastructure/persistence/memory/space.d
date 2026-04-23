/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.space;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.space;
import uim.platform.foundry.domain.ports.repositories.space;

// import std.algorithm : filter;
// import std.array : array;

class MemorySpaceRepository : TenantRepository!(Space, SpaceId), SpaceRepository {

  size_t countByOrg(OrgId orgId, TenantId tenantId) {
    return findByOrg(orgId, tenantId).length;
  }

  Space findByName(OrgId orgId, TenantId tenantId, string name) {
    foreach (e; findByTenant)
      if (e.tenantId == tenantId && e.orgId == orgId && e.name == name)
        return e;
    return null;
  }

  Space[] findByOrg(OrgId orgId, TenantId tenantId) {
    return findAll.filter!(e => e.tenantId == tenantId && e.orgId == orgId).array;
  }

}
