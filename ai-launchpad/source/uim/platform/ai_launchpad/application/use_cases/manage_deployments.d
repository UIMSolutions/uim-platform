/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.use_cases.manage_deployments;

import uim.platform.ai_launchpad.domain.ports.deployment_repository;
import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageDeploymentsUseCase : UIMUseCase {
  private IDeploymentRepository repo;

  this(IDeploymentRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDeploymentRequest r) {
    Deployment d;
    d.id = randomUUID().to!string;
    d.connectionId = r.connectionId;
    d.configurationId = r.configurationId;
    d.resourceGroupId = r.resourceGroupId;
    d.ttl = r.ttl;
    d.status = DeploymentStatus.pending;
    d.createdAt = "now";
    d.modifiedAt = "now";
    repo.save(d);
    return CommandResult(true, d.id, "");
  }

  Deployment get_(DeploymentId id, ConnectionId connectionId) {
    return repo.findById(id, connectionId);
  }

  Deployment[] listByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  Deployment[] listByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    return repo.findByScenario(scenarioId, connectionId);
  }

  CommandResult patch(PatchDeploymentRequest r) {
    auto d = repo.findById(r.deploymentId, r.connectionId);
    if (d.id.length == 0) return CommandResult(false, "", "Deployment not found");
    d.targetStatus = r.targetStatus;
    if (r.targetStatus == "stopped") d.status = DeploymentStatus.stopped;
    else if (r.targetStatus == "deleted") d.status = DeploymentStatus.dead;
    if (r.configurationId.length > 0) d.configurationId = r.configurationId;
    if (r.ttl > 0) d.ttl = r.ttl;
    d.modifiedAt = "now";
    repo.save(d);
    return CommandResult(true, d.id, "");
  }

  CommandResult[] bulkPatch(BulkPatchDeploymentRequest r) {
    CommandResult[] results;
    foreach (ref did; r.deploymentIds) {
      PatchDeploymentRequest pr;
      pr.connectionId = r.connectionId;
      pr.deploymentId = did;
      pr.targetStatus = r.targetStatus;
      results ~= patch(pr);
    }
    return results;
  }

  CommandResult remove(DeploymentId id, ConnectionId connectionId) {
    auto d = repo.findById(id, connectionId);
    if (d.id.length == 0) return CommandResult(false, "", "Deployment not found");
    repo.remove(id, connectionId);
    return CommandResult(true, id, "");
  }
}
