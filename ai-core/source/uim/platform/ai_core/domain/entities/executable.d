/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.executable;

// import uim.platform.ai_core.domain.types;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
struct InputArtifactBinding {
  string key;
  ArtifactKind kind;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("kind", kind.to!string)
      .set("description", description);
  }
}

struct OutputArtifactBinding {
  string key;
  ArtifactKind kind;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("kind", kind.to!string)
      .set("description", description);
  }
}

struct ParameterBinding {
  string key;
  string type;
  string default_;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("type", type)
      .set("default", default_)
      .set("description", description);
  }
}

struct Executable {
  mixin TenantEntity!(ExecutableId);

  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  string name;
  string description;
  ExecutableType type;
  string versionId;
  InputArtifactBinding[] inputArtifacts;
  OutputArtifactBinding[] outputArtifacts;
  ParameterBinding[] parameters;
  string[] labels;
  string deployable;

  Json toJson() const {
    auto j = entityToJson
      .set("resourceGroupId", resourceGroupId)
      .set("scenarioId", scenarioId)
      .set("name", name)
      .set("description", description)
      .set("type", type.to!string)
      .set("versionId", versionId)
      .set("inputArtifacts", inputArtifacts.map!(i => i.toJson()).array.toJson)
      .set("outputArtifacts", outputArtifacts.map!(o => o.toJson()).array.toJson)
      .set("parameters", parameters.map!(p => p.toJson()).array.toJson)
      .set("labels", labels.toJson)
      .set("deployable", deployable);

    return j;
  }
}
