/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.deployments;
// import uim.platform.ai_launchpad.domain.ports.repositories.deployments;
// import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageDeploymentsUseCase {
  protected IDeploymentRepository repo;

  this(IDeploymentRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createDeployment(CreateDeploymentRequest r) {
    auto d = Deployment(r.tenantId);
    d.connectionId = r.connectionId;
    d.configurationId = r.configurationId;
    d.resourceGroupId = r.resourceGroupId;
    d.ttl = r.ttl;
    d.status = DeploymentStatus.pending;

    repo.save(d);
    return UsecaseResult(true, d.id.value, "");
  }

  Deployment getDeployment(TenantId tenantId, ConnectionId connectionId, DeploymentId id) {
    return repo.findById(tenantId, connectionId, id);
  }

  Deployment[] listDeployments(TenantId tenantId, ConnectionId connectionId) {
    return repo.findByConnection(tenantId, connectionId);
  }

  Deployment[] listDeployments(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return repo.findByScenario(tenantId, connectionId, scenarioId);
  }

  UsecaseResult patchDeployment(PatchDeploymentRequest r) {
    auto d = repo.findById(r.tenantId, r.connectionId, r.deploymentId);
    if (d.isNull)
      return UsecaseResult(false, "", "Deployment not found");

    d.targetStatus = r.targetStatus;
    if (r.targetStatus == "stopped")
      d.status = DeploymentStatus.stopped;
    else if (r.targetStatus == "deleted")
      d.status = DeploymentStatus.dead;
    if (!r.configurationId.isEmpty)
      d.configurationId = r.configurationId;
    if (r.ttl > 0)
      d.ttl = r.ttl;
    d.updatedAt = currentTimestamp();

    repo.save(d);
    return UsecaseResult(true, d.id.value, "");
  }

  UsecaseResult[] bulkPatchDeployments(BulkPatchDeploymentRequest r) {
    UsecaseResult[] results;
    foreach (did; r.deploymentIds) {
      PatchDeploymentRequest pr;
      pr.tenantId = r.tenantId;
      pr.connectionId = r.connectionId;
      pr.deploymentId = did;
      pr.targetStatus = r.targetStatus;
      results ~= patchDeployment(pr);
    }
    return results;
  }

  UsecaseResult deleteDeployment(TenantId tenantId, ConnectionId connectionId, DeploymentId id) {
    auto deployment = repo.findById(tenantId, connectionId, id);
    if (deployment.isNull)
      return UsecaseResult(false, "", "Deployment not found");

    repo.remove(deployment);
    return UsecaseResult(true, deployment.id.value, "");
  }
}
