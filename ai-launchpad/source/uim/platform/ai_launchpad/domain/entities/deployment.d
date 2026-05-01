/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.deployment;

import uim.platform.ai_launchpad.domain.types;

struct ScalingConfig {
  int minReplicas;
  int maxReplicas;
}

struct Deployment {
  DeploymentId id;
  ConnectionId connectionId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  string resourceGroupId;
  DeploymentStatus status;
  string targetStatus;
  string deploymentUrl;
  ScalingConfig scaling;
  int ttl;
  string startedAt;
  string stoppedAt;
  string statusMessage;
  string createdAt;
  string updatedAt;

  Json toJson() {
    import std.conv : to;
    import uim.platform.ai_launchpad.domain.entities.deployment : ScalingConfig;

    auto sj = Json.emptyObject
      .set("minReplicas", scaling.minReplicas)
      .set("maxReplicas", scaling.maxReplicas);

    return Json.emptyObject
      .set("id", id)
      .set("connectionId", connectionId)
      .set("configurationId", configurationId)
      .set("scenarioId", scenarioId)
      .set("resourceGroupId", resourceGroupId)
      .set("status", status.to!string)
      .set("targetStatus", targetStatus)
      .set("deploymentUrl", deploymentUrl)
      .set("scaling", sj)
      .set("ttl", ttl)
      .set("startedAt", startedAt)
      .set("stoppedAt", stoppedAt)
      .set("statusMessage", statusMessage)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }
}
