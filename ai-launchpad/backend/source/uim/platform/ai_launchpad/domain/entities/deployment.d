/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A deployment serves the serving executable of a configuration as an
/// inference endpoint with 1..10 replicas and an optional time to live.
///
///   pending ──running──▶ running ──stop / TTL──▶ stopped ──restart──▶ pending
///   pending ──fails──▶ dead
module uim.platform.ai_launchpad.domain.entities.deployment;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum int maxReplicasLimit = 10;

struct Deployment {
  mixin TenantEntity!DeploymentId;

  ConfigurationId configurationId;
  ScenarioId scenarioId; /// derived from the configuration
  ConnectionId connectionId; /// derived from the configuration
  ResourceGroupId resourceGroupId;
  DeploymentStatus status = DeploymentStatus.pending;
  string statusMessage;
  string deploymentUrl; /// inference URL once running
  int minReplicas = 1;
  int maxReplicas = 1;
  int ttlMinutes; /// 0 = unlimited
  long startedAt;
  long stoppedAt;

  bool isActive() const {
    return status == DeploymentStatus.pending || status == DeploymentStatus.running;
  }

  /// Running longer than the time to live.
  bool isExpiredAt(long now) const {
    return status == DeploymentStatus.running && ttlMinutes > 0 && startedAt > 0 && now >= plusMinutes(startedAt, ttlMinutes);
  }

  void markRunning(long now, string url) {
    if (status != DeploymentStatus.pending)
      throw AilpException.ruleViolation("Deployment '" ~ id.value ~ "' is " ~ cast(string) status ~ ", not pending");
    status = DeploymentStatus.running;
    deploymentUrl = url;
    startedAt = now;
    stoppedAt = 0;
    statusMessage = "Serving";
  }

  void markDead(string message) {
    status = DeploymentStatus.dead;
    deploymentUrl = "";
    statusMessage = message;
  }

  void stop(long now, string reason) {
    if (!isActive)
      throw AilpException.ruleViolation("Deployment '" ~ id.value ~ "' is already " ~ cast(string) status);
    status = DeploymentStatus.stopped;
    deploymentUrl = "";
    stoppedAt = now;
    statusMessage = reason;
  }

  void restart() {
    if (status != DeploymentStatus.stopped && status != DeploymentStatus.dead)
      throw AilpException.ruleViolation("Deployment '" ~ id.value ~ "' is " ~ cast(string) status
          ~ ": only stopped or dead deployments can be started");
    status = DeploymentStatus.pending;
    statusMessage = "Restart requested";
  }

  void validate() const {
    requireId(id.value, "Deployment ID");
    requireId(configurationId.value, "Configuration");
    requireId(resourceGroupId.value, "Resource group");
    requireRange(minReplicas, 1, maxReplicasLimit, "Minimum replicas");
    requireRange(maxReplicas, 1, maxReplicasLimit, "Maximum replicas");
    if (minReplicas > maxReplicas)
      throw AilpException.invalid("The minimum replicas must not exceed the maximum replicas");
    requireRange(ttlMinutes, 0, 525_600, "Time to live (minutes)");
  }
}

///
unittest {
  Deployment d;
  d.id = DeploymentId("d1");
  d.configurationId = ConfigurationId("cfg");
  d.resourceGroupId = ResourceGroupId("default");
  d.ttlMinutes = 60;
  d.validate();
  auto t = parseIsoTime("2026-11-27T10:00:00Z");
  d.markRunning(t, "https://x.example/v2/inference/deployments/d1");
  assert(d.isActive && !d.isExpiredAt(plusMinutes(t, 59)) && d.isExpiredAt(plusMinutes(t, 60)));
  d.stop(plusMinutes(t, 60), "TTL reached");
  assert(d.status == DeploymentStatus.stopped && d.deploymentUrl == "");
  d.restart();
  assert(d.status == DeploymentStatus.pending);
  d.minReplicas = 3;
  d.maxReplicas = 2;
  assert(failsWith(AilpErrorKind.invalid, () { d.validate(); }));
}
