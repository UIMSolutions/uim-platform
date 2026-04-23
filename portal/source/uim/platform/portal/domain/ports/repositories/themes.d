/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.themes;

// import uim.platform.portal.domain.entities.theme;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Port: outgoing — theme persistence.
interface ThemeRepository : ITenantRepository!(Theme, ThemeId) {

  bool existsDefault(TenantId tenantId);
  Theme findDefault(TenantId tenantId);
  void removeDefault(TenantId tenantId);
  
}
