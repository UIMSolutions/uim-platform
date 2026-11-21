/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A deployment serves a model (serving configuration) under an inference URL.
module uim.platform.ai_core.domain.entities.deployment;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Deployment {
  mixin TenantEntity!DeploymentId;

  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  ConfigurationId latestRunningConfigurationId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  DeploymentStatus status = DeploymentStatus.unknown;
  TargetStatus targetStatus = TargetStatus.running;
  DeploymentOperation lastOperation = DeploymentOperation.create;
  string statusMessage;
  string deploymentUrl;
  long ttlSeconds; /// 0 = unlimited
  long submissionTime;
  long startTime;
  long completionTime;

  /// Point in time at which the TTL stops the deployment (0 = never).
  long expiresAt() const {
    return ttlSeconds > 0 && startTime > 0 ? plusSeconds(startTime, ttlSeconds) : 0;
  }
}
