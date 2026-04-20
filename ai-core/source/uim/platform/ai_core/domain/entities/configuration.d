/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.configuration;

import uim.platform.ai_core.domain.types;

struct ParameterValue {
  string key;
  string value;
}

struct InputArtifactRef {
  string key;
  ArtifactId artifactId;
}

struct Configuration {
  mixin TenantEntity!(ConfigurationId);

  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  string name;
  ParameterValue[] parameterValues;
  InputArtifactRef[] inputArtifacts;

  Json toJson() const {
    auto j = entityToJson
      .set("resourceGroupId", resourceGroupId)
      .set("scenarioId", scenarioId)
      .set("executableId", executableId)
      .set("name", name);

    if (parameterValues.length > 0) {
      auto pvs = parameterValues.map!(p => Json.emptyObject.set("key", p.key).set("value", p.value)).array.toJson;
      j["parameterValues"] = pvs;
    }

    if (inputArtifacts.length > 0) {
      auto iars = inputArtifacts.map!(i => Json.emptyObject.set("key", i.key).set("artifactId", i.artifactId)).array.toJson;
      j["inputArtifacts"] = iars;
    }

    return j;
  }
}
