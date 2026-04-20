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

class MemoryAppRepository : AppRepository {
  private Application[AppId] store;

  Application[] findBySpace(SpaceId spaceId, id tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.spaceId == spaceId).array;
  }

  Application* findById(AppId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Application* findByName(SpaceId spaceId, id tenantId, string name) {
    foreach (e; store.byValue())
      if (e.tenantId == tenantId && e.spaceId == spaceId && e.name == name)
        return &e;
    return null;
  }

  Application[] findByState(SpaceId spaceId, id tenantId, AppState state) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.spaceId == spaceId && e.state == state).array;
  }

  Application[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  size_t countBySpace(SpaceId spaceId, id tenantId) {
    return findBySpace(spaceId, id).length;
  }

  void save(Application app) {
    store[app.id] = app;
  }

  void update(Application app) {
    store[app.id] = app;
  }

  void remove(AppId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
