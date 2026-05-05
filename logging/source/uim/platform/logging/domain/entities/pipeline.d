/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.pipeline;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct PipelineProcessor {
  ProcessorType type = ProcessorType.filter;
  string name;
  string config;
  int order_;

  Json toJson() const {
    return Json.emptyObject
      .set("type", type.to!string())
      .set("name", name)
      .set("config", config)
      .set("order_", order_);
  }
}

struct Pipeline {
  mixin TenantEntity!PipelineId;

  string name;
  string description;
  PipelineSourceType sourceType = PipelineSourceType.custom;
  PipelineFormat format = PipelineFormat.json;
  PipelineProcessor[] processors;
  LogStreamId targetStreamId;
  bool isActive = true;
  
  Json toJson() const {
    auto procsJson = Json.emptyArray;
    foreach (proc; processors) {
      procsJson ~= proc.toJson();
    }

    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("sourceType", sourceType.to!string())
      .set("format", format.to!string())
      .set("processors", procsJson)
      .set("targetStreamId", targetStreamId)
      .set("isActive", isActive);
  }
}
