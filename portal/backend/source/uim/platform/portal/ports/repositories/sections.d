/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.repositories.sections;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

interface ISectionRepository : ITenantRepository!(PortalSection, SectionId) {
  PortalSection[] findByPage(TenantId tenantId, PageId pageId);
  PortalSection[] findBySite(TenantId tenantId, SiteId siteId);
  /// Sections that show the tile.
  PortalSection[] findByTile(TenantId tenantId, TileId tileId);
}
