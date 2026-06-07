/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.model;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

struct Model {
  mixin TenantEntity!ModelId;

  ConnectionId connectionId;
  ScenarioId scenarioId;
  ExecutionId executionId;

  string name;
  string version_;
  string description;
  string url;
  long size;
  ModelStatus status;
  string[] labels;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
      .set("connectionId", connectionId)
      .set("name", name)
      .set("version", version_)
      .set("description", description)
      .set("scenarioId", scenarioId)
      .set("executionId", executionId)
      .set("url", url)
      .set("size", size)
      .set("status", status.to!string)
      .set("labels", labels.map!(l => l.toJson()).array.toJson);
  }
}
