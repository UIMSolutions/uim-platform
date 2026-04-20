/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.page;

// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// A page within a site; contains sections.
struct Page {
  mixin TenantEntity!(PageId);

  SiteId siteId;
  string title;
  string description;
  string alias_; // URL-friendly path
  PageLayout layout = PageLayout.freeform;
  SectionId[] sectionIds;
  RoleId[] allowedRoleIds;
  int sortOrder;
  bool visible = true;

  Json toJson() const {
      return entityToJson
          .set("siteId", siteId.value)
          .set("title", title)
          .set("description", description)
          .set("alias", alias_)
          .set("layout", layout.to!string())
          .set("sectionIds", sectionIds)
          .set("allowedRoleIds", allowedRoleIds)
          .set("sortOrder", sortOrder)
          .set("visible", visible);
  }
}
