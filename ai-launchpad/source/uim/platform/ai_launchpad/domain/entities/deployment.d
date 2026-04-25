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
}
