/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.page_template;

import uim.platform.workzone.domain.types;

/// A page template — reusable layout definition for workpages.
struct PageTemplate {
  PageTemplateId id;
  TenantId tenantId;
  string name;
  string description;
  string thumbnailUrl;
  TemplateSection[] sections;
  bool isDefault;
  bool isPublic;
  long createdAt;
  long updatedAt;
}

/// A section within a page template.
struct TemplateSection {
  string sectionId;
  string title;
  int columns;
  string layoutType; // "grid", "list", "tabs"
  int sortOrder;
  WidgetSize[] allowedWidgetSizes;
}
