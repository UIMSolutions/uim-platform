/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.data_flow;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct FlowSource {
  string objectId;
  string objectType;
  string[] columns;

  Json toJson() const {
    return Json.emptyObject
      .set("objectId", objectId)
      .set("objectType", objectType)
      .set("columns", columns);
  }
}

struct FlowTarget {
  string objectId;
  string objectType;
  string truncateMode;

  Json toJson() const {
    return Json.emptyObject
      .set("objectId", objectId)
      .set("objectType", objectType)
      .set("truncateMode", truncateMode);
  }
}

struct FlowTransform {
  string name;
  string type;
  string expression;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("type", type)
      .set("expression", expression);
  }
}

struct DataFlow {
  mixin TenantEntity!DataFlowId;

  SpaceId spaceId;
  string name;
  string description;
  FlowStatus status;
  FlowSource[] sources;
  FlowTarget target;
  FlowTransform[] transforms;
  string scheduleExpression;
  ScheduleFrequency scheduleFrequency;
  long lastRunAt;
  long lastRunDurationMs;
  string lastRunMessage;
  
  Json toJson() const {
    auto sourcesJson = Json.emptyArray;
    foreach (source; sources) {
      sourcesJson ~= source.toJson();
    }

    auto transformsJson = Json.emptyArray;
    foreach (transform; transforms) {
      transformsJson ~= transform.toJson();
    }

    return entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string())
      .set("sources", sourcesJson)
      .set("target", target.toJson())
      .set("transforms", transformsJson)
      .set("scheduleExpression", scheduleExpression)
      .set("scheduleFrequency", scheduleFrequency.to!string())
      .set("lastRunAt", lastRunAt)
      .set("lastRunDurationMs", lastRunDurationMs)
      .set("lastRunMessage", lastRunMessage);
  }
}
