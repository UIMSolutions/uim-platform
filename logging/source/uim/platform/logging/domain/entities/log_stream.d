/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.log_stream;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct LogStream {
  mixin TenantEntity!(LogStreamId);

  string name;
  string description;
  LogSourceType sourceType = LogSourceType.application;
  RetentionPolicyId retentionPolicyId;
  bool isActive = true;
  string createdBy;
  
  Json toJson() const {
    return Json.entityToJson
      .set("name", name)
      .set("description", description)
      .set("sourceType", sourceType.to!string)
      .set("retentionPolicyId", retentionPolicyId)
      .set("isActive", isActive)
      .set("createdBy", createdBy);
  }
}
