/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.execution;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct OutputArtifact {
  string name;
  string artifactId;
  string artifactUrl;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("artifactId", artifactId)
      .set("artifactUrl", artifactUrl);
  }
}

struct Execution {
  mixin TenantEntity!ExecutionId;

  ConnectionId connectionId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  string resourceGroupId;
  ExecutionStatus status;
  string targetStatus;
  OutputArtifact[] outputArtifacts;
  long startedAt;
  long completedAt;
  long duration;
  string logsUrl;
  string statusMessage;

  Json toJson() const {
    auto artifacts = outputArtifacts.map!(a => a.toJson).array.toJson;

    return entityToJson
      .set("connectionId", connectionId)
      .set("configurationId", configurationId)
      .set("scenarioId", scenarioId)
      .set("resourceGroupId", resourceGroupId)
      .set("status", status.to!string)
      .set("targetStatus", targetStatus)
      .set("outputArtifacts", artifacts)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("duration", duration)
      .set("logsUrl", logsUrl)
      .set("statusMessage", statusMessage);
  }
}
