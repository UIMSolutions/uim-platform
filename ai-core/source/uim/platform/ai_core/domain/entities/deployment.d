/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.deployment;

import uim.platform.ai_core.domain.types;

struct Deployment {
  mixin TenantEntity!(DeploymentId);

  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  DeploymentStatus status;
  TargetStatus targetStatus;
  string statusMessage;
  string deploymentUrl;
  int ttl;
  string lastOperation;
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
      .set("deploymentUrl", deploymentUrl)
      .set("ttl", ttl)
      .set("lastOperation", lastOperation)
      .set("completedAt", completedAt);

    return j;
  }
}
