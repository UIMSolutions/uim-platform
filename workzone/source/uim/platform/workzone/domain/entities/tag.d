/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.tag;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A tag / category — for content tagging and categorization.
struct Tag {
  mixin TenantEntity!(TagId);

  string name;
  string description;
  string color;
  string parentTagId; // for hierarchical categories
  int usageCount;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("color", color)
      .set("parentTagId", parentTagId)
      .set("usageCount", usageCount);
  }
}
