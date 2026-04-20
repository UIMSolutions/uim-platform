/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.page_template;

import uim.platform.workzone.domain.types;

/// A page template — reusable layout definition for workpages.
struct PageTemplate {
  mixin TenantEntity!(PageTemplateId);
  
  string name;
  string description;
  string thumbnailUrl;
  TemplateSection[] sections;
  bool isDefault;
  bool isPublic;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("thumbnailUrl", thumbnailUrl)
      .set("sections", sections.map!(s => s.toJson()).array)
      .set("isDefault", isDefault)
      .set("isPublic", isPublic);
  }
}

/// A section within a page template.
struct TemplateSection {
  string sectionId;
  string title;
  int columns;
  string layoutType; // "grid", "list", "tabs"
  int sortOrder;
  WidgetSize[] allowedWidgetSizes;

  Json toJson() const {
    return Json.emptyObject
      .set("sectionId", sectionId)
      .set("title", title)
      .set("columns", columns)
      .set("layoutType", layoutType)
      .set("sortOrder", sortOrder)
      .set("allowedWidgetSizes", allowedWidgetSizes.map!(s => s.toJson()).array);
  }

}
