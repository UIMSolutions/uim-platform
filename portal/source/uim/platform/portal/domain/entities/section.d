/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.section;

import uim.platform.portal.domain.types;

/// A section within a page — groups tiles together.
struct Section
{
  SectionId id;
  PageId pageId;
  TenantId tenantId;
  string title;
  TileId[] tileIds;
  int sortOrder;
  bool visible = true;
  int columns = 4; // grid columns
  long createdAt;
  long updatedAt;
}
