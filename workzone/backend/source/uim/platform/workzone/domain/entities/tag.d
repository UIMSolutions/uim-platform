/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.tag;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A tag / category (hierarchical via parentTag).
struct Tag {
  mixin TenantEntity!TagId;

  string name; /// unique per tenant
  string description;
  string color = "#0A6ED1";
  string parentTag; /// name of the parent tag
}
