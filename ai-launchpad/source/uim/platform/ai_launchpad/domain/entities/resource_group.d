/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.resource_group;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

struct LabelPair {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct ResourceGroup {
  mixin TenantEntity!ResourceGroupId;

  ConnectionId connectionId;
  LabelPair[] labels;
  string status;
  
  Json toJson() const {
    return entityToJson
      .set("connection_id", connectionId)
      .set("labels", labels.map!(l => l.toJson()).array.toJson)
      .set("status", status);
  }
}
