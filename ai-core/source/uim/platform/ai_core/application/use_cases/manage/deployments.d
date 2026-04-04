/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage_deployments;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.deployment;
import uim.platform.ai_core.domain.ports.repositories.deployments;
import uim.platform.ai_core.domain.ports.repositories.configurations;
import uim.platform.ai_core.domain.services.execution_scheduler;
import uim.platform.ai_core.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageDeploymentsUseCase : UIMUseCase {
  private DeploymentRepository deplRepo;
  private ConfigurationRepository confRepo;

  this(DeploymentRepository deplRepo, ConfigurationRepository confRepo) {
    this.deplRepo = deplRepo;
    this.confRepo = confRepo;
  }

  CommandResult create(CreateDeploymentRequest r) {
    if (r.configurationId.length == 0)
      return CommandResult(false, "", "Configuration ID is required");
    if (r.resourceGroupId.length == 0)
      return CommandResult(false, "", "Resource group ID is required");

    auto conf = confRepo.findById(r.configurationId, r.resourceGroupId);
    if (conf.id.length == 0)
      return CommandResult(false, "", "Configuration not found");

    Deployment d;
    d.id = randomUUID().to!string;
    d.tenantId = r.tenantId;
    d.resourceGroupId = r.resourceGroupId;
    d.configurationId = r.configurationId;
    d.scenarioId = conf.scenarioId;
    d.executableId = conf.executableId;
    d.status = DeploymentStatus.pending;
    d.statusMessage = "Deployment created and pending";
    d.ttl = r.ttl;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    d.createdAt = now;
    d.modifiedAt = now;

    deplRepo.save(d);
    return CommandResult(true, d.id, "");
  }

  CommandResult patch(PatchDeploymentRequest r) {
    auto d = deplRepo.findById(r.deploymentId, r.resourceGroupId);
    if (d.id.length == 0)
      return CommandResult(false, "", "Deployment not found");

    if (r.targetStatus.length > 0) {
      TargetStatus target;
      if (r.targetStatus == "stopped")
        target = TargetStatus.stopped;
      else if (r.targetStatus == "running")
        target = TargetStatus.running;
      else if (r.targetStatus == "deleted")
        target = TargetStatus.deleted_;
      else
        return CommandResult(false, "", "Invalid target status");

      if (!ExecutionScheduler.canTransitionDeployment(d.status, target))
        return CommandResult(false, "", "Cannot transition to target status from current status");

      d.targetStatus = target;
      if (target == TargetStatus.stopped)
        d.status = DeploymentStatus.stopped;
      else if (target == TargetStatus.running)
        d.status = DeploymentStatus.running;
      else if (target == TargetStatus.deleted_)
        d.status = DeploymentStatus.dead;
    }

    // Support configuration update for running deployments
    if (r.configurationId.length > 0)
      d.configurationId = r.configurationId;

    if (r.ttl > 0)
      d.ttl = r.ttl;

    import core.time : MonoTime;
    d.modifiedAt = MonoTime.currTime.ticks;

    deplRepo.update(d);
    return CommandResult(true, d.id, "");
  }

  Deployment get_(DeploymentId id, ResourceGroupId rgId) {
    return deplRepo.findById(id, rgId);
  }

  Deployment[] list(ResourceGroupId rgId) {
    return deplRepo.findByResourceGroup(rgId);
  }

  Deployment[] listByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    return deplRepo.findByScenario(scenarioId, rgId);
  }

  Deployment[] listByStatus(DeploymentStatus status, ResourceGroupId rgId) {
    return deplRepo.findByStatus(status, rgId);
  }

  CommandResult remove(DeploymentId id, ResourceGroupId rgId) {
    auto existing = deplRepo.findById(id, rgId);
    if (existing.id.length == 0)
      return CommandResult(false, "", "Deployment not found");

    deplRepo.remove(id, rgId);
    return CommandResult(true, id, "");
  }

  long count(ResourceGroupId rgId) {
    return deplRepo.countByResourceGroup(rgId);
  }
}
