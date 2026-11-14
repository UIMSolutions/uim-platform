/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.repositories.sites;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

interface ISiteRepository : ITenantRepository!(PortalSite, SiteId) {
  PortalSite findByAlias(TenantId tenantId, string alias_);
  PortalSite[] findByTheme(TenantId tenantId, ThemeId themeId);
}
