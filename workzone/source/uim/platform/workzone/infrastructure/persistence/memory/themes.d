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

class MemoryThemeRepository : TenantRepository!(Theme, ThemeId), ThemeRepository {

  bool existsDefault(TenantId tenantId) {
    return findByTenant(tenantId).any!(t => t.isDefault);
  }

  Theme findDefault(TenantId tenantId) {
    foreach (t; findByTenant(tenantId))
      if (t.isDefault)
        return t;
    return Theme.init;
  }

  void removeDefault(TenantId tenantId) {
    foreach (t; findByTenant(tenantId))
      if (t.isDefault) {
        remove(t);
        break;
      }
  }
}
