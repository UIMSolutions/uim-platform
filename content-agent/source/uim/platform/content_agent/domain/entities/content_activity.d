/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.content_activity;

// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Audit record for a content operation.
struct ContentActivity {
  mixin TenantEntity!(ContentActivityId);

  ActivityType activityType;
  ActivitySeverity severity = ActivitySeverity.info;
  string entityId;
  string entityName;
  string description;
  UserId performedBy;
  long timestamp;
  string details;

  Json toJson() const {
    return entityToJson
      .set("activityType", activityType.to!string)
      .set("severity", severity.to!string)
      .set("entityId", entityId)
      .set("entityName", entityName)
      .set("description", description)
      .set("performedBy", performedBy)
      .set("timestamp", timestamp)
      .set("details", details);
  }
}
