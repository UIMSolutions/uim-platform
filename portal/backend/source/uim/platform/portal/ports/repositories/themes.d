/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.repositories.themes;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

interface IThemeRepository : ITenantRepository!(PortalTheme, ThemeId) {
  PortalTheme findByName(TenantId tenantId, string name);
  /// The tenant default theme (isNull if none).
  PortalTheme findDefault(TenantId tenantId);
}
