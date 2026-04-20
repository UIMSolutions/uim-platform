/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.execution;

import uim.platform.ai_core.domain.types;

struct OutputArtifactRef {
  string key;
  ArtifactId artifactId;
}

struct Execution {
  mixin TenantEntity!(ExecutionId);

  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  ExecutionStatus status;
  TargetStatus targetStatus;
  string statusMessage;
  OutputArtifactRef[] outputArtifacts;
  long startedAt;
  long completedAt;

  Json toJson() const {
    auto j = entityToJson
      .set("resourceGroupId", resourceGroupId)
      .set("configurationId", configurationId)
      .set("scenarioId", scenarioId)
      .set("executableId", executableId)
      .set("status", status.to!string)
      .set("targetStatus", targetStatus.to!string)
      .set("statusMessage", statusMessage)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt);

    if (outputArtifacts.length > 0) {
      auto oars = outputArtifacts.map!(o => Json.emptyObject.set("key", o.key).set("artifactId", o.artifactId)).array.toJson;
      j["outputArtifacts"] = oars;
    }

    return j;
  }
}
