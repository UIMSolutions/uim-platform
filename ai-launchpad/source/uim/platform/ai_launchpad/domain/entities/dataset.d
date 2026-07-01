/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.dataset;

//import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Dataset {
  mixin TenantEntity!DatasetId;

  ConnectionId connectionId;
  ScenarioId scenarioId;
  
  string name;
  string description;
  string url;
  long size;
  DatasetStatus status;
  string[] labels;
  long createdAt;
  long updatedAt;

  Json toJson() {

    return entityToJson
      .set("connectionId", connectionId)
      .set("name", name)
      .set("description", description)
      .set("scenarioId", scenarioId)
      .set("url", url)
      .set("size", size)
      .set("status", status.to!string)
      .set("labels", labels.map!(l => l.toJson).array.toJson);
  }
}
