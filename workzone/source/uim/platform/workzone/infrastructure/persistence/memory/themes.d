/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.themes;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.theme;
import uim.platform.workzone.domain.ports.repositories.themes;

// import std.algorithm : filter;
// import std.array : array;

class MemoryThemeRepository : ThemeRepository {
  private Theme[ThemeId] store;

  Theme[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(t => t.tenantId == tenantId).array;
  }

  Theme* findById(ThemeId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Theme* findDefault(TenantId tenantId) {
    foreach (ref t; store.byValue())
      if (t.tenantId == tenantId && t.isDefault)
        return &t;
    return null;
  }

  void save(Theme theme) {
    store[theme.id] = theme;
  }

  void update(Theme theme) {
    store[theme.id] = theme;
  }

  void remove(ThemeId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
