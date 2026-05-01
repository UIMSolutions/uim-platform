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
  DatasetId id;
  ConnectionId connectionId;
  string name;
  string description;
  ScenarioId scenarioId;
  string url;
  long size;
  DatasetStatus status;
  string[] labels;
  string createdAt;
  string updatedAt;

  Json toJson() {

    return Json.emptyObject
      .set("id", id)
      .set("connectionId", connectionId)
      .set("name", name)
      .set("description", description)
      .set("scenarioId", scenarioId)
      .set("url", url)
      .set("size", size)
      .set("status", status.to!string)
      .set("labels", JsonArray(d.labels))
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }
}
