/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.spaces;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.space;
// import uim.platform.foundry.domain.ports.repositories.space;


 
import uim.platform.foundry;

// mixin(ShowModule!());

@safe:
class MemorySpaceRepository : TenantRepository!(Space, SpaceId), ISpaceRepository {

  bool existsByName(TenantId tenantId, OrgId orgId, string name) {
    return find(tenantId).any!(e => e.orgId == orgId && e.name == name);
  }

  Space findByName(TenantId tenantId, OrgId orgId, string name) {
    foreach (e; find(tenantId))
      if (e.orgId == orgId && e.name == name)
        return e;
    return Space.init;
  }
  
  void removeByName(TenantId tenantId, OrgId orgId, string name) {
    auto e = findByName(tenantId, orgId, name);
    if (!e.isNull)
      remove(e);
  }

  size_t countByOrg(TenantId tenantId, OrgId orgId) {
    return findByOrg(tenantId, orgId).length;
  }

  Space[] filterByOrg(Space[] spaces, OrgId orgId) {
    return spaces.filter!(e => e.orgId == orgId).array;
  }

  Space[] findByOrg(TenantId tenantId, OrgId orgId) {
    return filterByOrg(find(tenantId), orgId);
  }

  void removeByOrg(TenantId tenantId, OrgId orgId) {
    findByOrg(tenantId, orgId).each!(e => remove(e));
  }

}
