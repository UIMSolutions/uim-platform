/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.themes;

// import uim.platform.portal.domain.entities.theme;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.themes;
import uim.platform.portal;
import uim.platform.portal.application.usecases.manage;

mixin(ShowModule!());

@safe:
class MemoryThemeRepository : TenantRepository!(Theme, ThemeId), ThemeRepository {

  bool existsDefault(TenantId tenantId) {
    return findByTenant(tenantId).any!(t => t.isDefault);
  }

  Theme findDefault(TenantId tenantId) {
    foreach (t; findByTenant(tenantId)) {
      if (t.tenantId == tenantId && t.isDefault)
        return t;
    }

    return Theme.init;
  }

}
