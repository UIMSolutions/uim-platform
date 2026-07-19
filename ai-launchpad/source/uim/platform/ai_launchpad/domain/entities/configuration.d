/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.configuration;

// import uim.platform.ai_launchpad.domain.types;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct ParameterBinding {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct InputArtifactBinding {
  string key;
  string artifactId;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("artifactId", artifactId);
  }
}

struct Configuration {
  mixin TenantEntity!ConfigurationId;

  ConnectionId connectionId;
  ScenarioId scenarioId;
  string executableId;
  
  string name;
  ParameterBinding[] parameters;
  InputArtifactBinding[] inputArtifacts;
  long createdAt;

  Json toJson() const {
    auto paramJson = parameters.map!(p => p.toJson()).array.toJson;
    auto artifactJson = inputArtifacts.map!(a => a.toJson()).array.toJson;

    return Json.emptyObject
      .set("id", id.value)
      .set("connectionId", connectionId.value)
      .set("scenarioId", scenarioId.value)
      .set("executableId", executableId)
      .set("name", name)
      .set("parameters", paramJson)
      .set("inputArtifacts", artifactJson)
      .set("createdAt", createdAt);
  }
}
