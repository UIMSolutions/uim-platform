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

class MemoryAppRepository : TenantRepository!(Application, AppId), AppRepository {

  bool existsByName(SpaceId spaceId, id tenantId, string name) {
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

  size_t countBySpace(SpaceId spaceId, id tenantId) {
    return findBySpace(spaceId, tenantId).length;
  }

  Application[] findBySpace(SpaceId spaceId, id tenantId) {
    return findByTenant(tenantId).filter!(e => e.spaceId == spaceId).array;
  }

  void removeBySpace(SpaceId spaceId, id tenantId) {
    findBySpace(spaceId, tenantId).each!(e => remove(e));
  }

  size_t countByState(SpaceId spaceId, id tenantId, AppState state) {
    return findByState(spaceId, tenantId, state).length;
  }

  Application[] findByState(SpaceId spaceId, id tenantId, AppState state) {
    return findByTenant(tenantId).filter!(e => e.spaceId == spaceId && e.state == state).array;
  }

  void removeByState(SpaceId spaceId, id tenantId, AppState state) {
    findByState(spaceId, tenantId, state).each!(e => remove(e));
  }

}
