/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.section;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A section of a page — arranges tiles of catalogs in a grid.
struct PortalSection {
  mixin TenantEntity!SectionId;

  SiteId siteId;
  PageId pageId;
  string name;
  string description;
  int sortOrder;
  bool visible = true;
  /// Grid columns (1 – 12).
  int columns = 4;
  /// Tiles shown in this section, in display order.
  TileId[] tileIds;
}
