/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.section;

// import uim.platform.portal.domain.types;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// A section within a page — groups tiles together.
struct PortalSection {
  mixin TenantEntity!(SectionId);

  PageId pageId;
  string title;
  TileId[] tileIds;
  int sortOrder;
  bool visible = true;
  int columns = 4; // grid columns
  
  Json toJson() const {
    return Json.enityToJson
      .set("id", id.value)
      .set("pageId", pageId.value)
      .set("title", title)
      .set("tileIds", tileIds.map!(t => t.value).array)
      .set("sortOrder", sortOrder)
      .set("visible", visible)
      .set("columns", columns);
  }
}
