/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.apps;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.application;
// import uim.platform.foundry.domain.ports.repositories.app;

import uim.platform.foundry;

mixin(ShowModule!());

@safe:

class MemoryAppRepository : TenantRepository!(Application, AppId), IAppRepository {

  bool existsByName(TenantId tenantId, SpaceId spaceId, string name) {
    return findByTenant(tenantId).any!(e => e.spaceId == spaceId && e.name == name);
  }

  Application findByName(TenantId tenantId, SpaceId spaceId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.spaceId == spaceId && e.name == name)
        return e;
    return Application.init;
  }

  void removeByName(TenantId tenantId, SpaceId spaceId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.spaceId == spaceId && e.name == name)
        return remove(e);
  }

  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }

  Application[] filterBySpace(Application[] apps, SpaceId spaceId) {
    return apps.filter!(e => e.spaceId == spaceId).array;
  }

  Application[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }

  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(e => remove(e));
  }
  // #endregion BySpace

  // #region ByState
  size_t countByState(TenantId tenantId, SpaceId spaceId, AppState state) {
    return findByState(tenantId, spaceId, state).length;
  }

  Application[] filterByState(Application[] apps, SpaceId spaceId, AppState state) {
    return apps.filter!(e => e.spaceId == spaceId && e.state == state).array;
  }

  Application[] findByState(TenantId tenantId, SpaceId spaceId, AppState state) {
    return filterByState(findByTenant(tenantId), spaceId, state);
  }

  void removeByState(TenantId tenantId, SpaceId spaceId, AppState state) {
    findByState(tenantId, spaceId, state).each!(e => remove(e));
  }
  // #endregion ByState
  
}
