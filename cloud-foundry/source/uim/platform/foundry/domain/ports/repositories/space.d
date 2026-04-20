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
interface SpaceRepository {
  Space[] findByOrg(OrgId orgtenantId, id tenantId);
  Space* findById(SpaceId tenantId, id tenantId);
  Space* findByName(OrgId orgtenantId, id tenantId, string name);
  Space[] findByTenant(TenantId tenantId);
  void save(Space space);
  void update(Space space);
  void remove(SpaceId tenantId, id tenantId);
  void removeByOrg(OrgId orgtenantId, id tenantId);
}
