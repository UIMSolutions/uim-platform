/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.metric;

// import uim.platform.ai_core.domain.types;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
struct MetricLabel {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct MetricTag {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct MetricValue {
  string name;
  string value;
  MetricValueType type;
  long timestamp;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("value", value)
      .set("type", type.to!string)
      .set("timestamp", timestamp);
  }
}

struct CustomInfo {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct Metric {
  mixin TenantEntity!(MetricId);

  ResourceGroupId resourceGroupId;
  ExecutionId executionId;
  MetricLabel[] labels;
  MetricTag[] tags;
  MetricValue[] metrics;
  CustomInfo[] customInfo;
  
  Json toJson() const {
    auto j = entityToJson
      .set("resourceGroupId", resourceGroupId)
      .set("executionId", executionId)
      .set("labels", labels.map!(l => l.toJson()).array.toJson)
      .set("tags", tags.map!(t => t.toJson()).array.toJson)
      .set("metrics", metrics.map!(m => m.toJson()).array.toJson)
      .set("customInfo", customInfo.map!(c => c.toJson()).array.toJson);

    return j;
  }
}
