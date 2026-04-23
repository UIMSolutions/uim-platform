/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.themes;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.theme;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface ThemeRepository : ITenantRepository!(Theme, ThemeId) {

  bool existsDefault(TenantId tenantId);
  Theme findDefault(TenantId tenantId);
  void removeDefault(TenantId tenantId);

}
