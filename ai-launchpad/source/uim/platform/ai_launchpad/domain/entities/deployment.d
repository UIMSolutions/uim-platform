/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.deployment;

import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

struct ScalingConfig {
  int minReplicas;
  int maxReplicas;

  Json toJson() const {
    return Json.emptyObject
      .set("minReplicas", minReplicas)
      .set("maxReplicas", maxReplicas);
  }
}

struct Deployment {
  mixin TenantEntity!DeploymentId;

  ConnectionId connectionId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  ResourceGroupId resourceGroupId;
  DeploymentStatus status;
  string targetStatus;
  string deploymentUrl;
  ScalingConfig scaling;
  int ttl;
  long startedAt;
  long stoppedAt;
  string statusMessage;

  Json toJson() const {    
    auto sj = Json.emptyObject
      .set("minReplicas", scaling.minReplicas)
      .set("maxReplicas", scaling.maxReplicas);

    return entityToJson()
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
      .set("statusMessage", statusMessage);
  }
}
