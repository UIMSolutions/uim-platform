/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.scenario;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

struct Scenario {
  mixin TenantEntity!ScenarioId;

  ConnectionId connectionId;
  string name;
  string description;
  string[] labels;
  int executionCount;
  int deploymentCount;
  
  Json toJson() const {
    return entityToJson
      .set("connection_id", connectionId)
      .set("name", name)
      .set("description", description)
      .set("labels", labels.toJson)
      .set("execution_count", executionCount)
      .set("deployment_count", deploymentCount);
  }
}
