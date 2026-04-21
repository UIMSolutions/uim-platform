/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.app;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.application;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying applications.
interface IAppRepository : ITenantRepository!(Application, AppId) {

  bool existsByName(TenantId tenantId, SpaceId spaceId, string name);
  Application findByName(TenantId tenantId, SpaceId spaceId, string name);
  void removeByName(TenantId tenantId, SpaceId spaceId, string name);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  Application[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countByState(TenantId tenantId, SpaceId spaceId, AppState state);
  Application[] findByState(TenantId tenantId, SpaceId spaceId, AppState state);
  void removeByState(TenantId tenantId, SpaceId spaceId, AppState state);
  
}
