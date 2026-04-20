/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.artifact;

import uim.platform.ai_core.domain.types;

struct ArtifactLabel {
  string key;
  string value;
}

struct Artifact {
  mixin TenantEntity!(ArtifactId);

  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutionId executionId;
  string name;
  string description;
  ArtifactKind kind;
  string url;
  ArtifactLabel[] labels;

  Json toJson() const {
    auto j = entityToJson
      .set("resourceGroupId", resourceGroupId)
      .set("scenarioId", scenarioId)
      .set("executionId", executionId)
      .set("name", name)
      .set("description", description)
      .set("kind", kind.to!string)
      .set("url", url);

    if (labels.length > 0) {
      auto lbls = labels.map!(l => Json.emptyObject.set("key", l.key).set("value", l.value)).array.toJson;
      j["labels"] = lbls;
    }

    return j;
  }
}
