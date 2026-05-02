/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.resource_group;

// import uim.platform.ai_core.domain.types;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
struct ResourceGroupLabel {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct ResourceGroup {
  mixin TenantEntity!(ResourceGroupId);

  string status;
  ResourceGroupLabel[] labels;
  
  Json toJson() const {
    auto j = entityToJson
      .set("status", status)
      .set("labels", labels.map!(l => l.toJson()).array.toJson);

    return j;
  }
}
