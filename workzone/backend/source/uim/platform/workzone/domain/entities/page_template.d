/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.page_template;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A layout template for new workpages.
struct PageTemplate {
  mixin TenantEntity!PageTemplateId;

  string name; /// unique per tenant
  string description;
  string thumbnailUrl;
  TemplateSection[] sections;
  bool isDefault;
  bool isPublic = true;
  bool predefined;
}
