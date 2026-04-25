/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.space;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.space;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying spaces.
interface ISpaceRepository : ITenantRepository!(Space, SpaceId) {
  bool existsByName(TenantId tenantId, OrgId orgId, string name);
  Space findByName(TenantId tenantId, OrgId orgId, string name);
  void removeByName(TenantId tenantId, OrgId orgId, string name);
  
  size_t countByOrg(TenantId tenantId, OrgId orgId);
  Space[] filterByOrg(TenantId tenantId, OrgId orgId);
  Space[] findByOrg(TenantId tenantId, OrgId orgId);
  void removeByOrg(TenantId tenantId, OrgId orgId);
}
