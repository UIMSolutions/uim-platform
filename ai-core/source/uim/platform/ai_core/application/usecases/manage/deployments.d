/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.deployments;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageDeploymentsUseCase {
  protected IDeploymentRepository deployments;
  protected IConfigurationRepository configurations;

  this(IDeploymentRepository deployments, IConfigurationRepository configurations) {
    this.deployments = deployments;
    this.configurations = configurations;
  }

  UsecaseResult createDeployment(CreateDeploymentRequest r) {
    if (r.configurationId.isEmpty)
      return UsecaseResult(false, "", "Configuration ID is required");
      
    if (r.resourceGroupId.isEmpty)
      return UsecaseResult(false, "", "Resource group ID is required");

    auto conf = configurations.findById(r.tenantId, r.resourceGroupId, r.configurationId);
    if (conf.isNull)
      return UsecaseResult(false, "", "Configuration not found");

    auto d = Deployment(r.tenantId, r.deploymentId.isNull ? DeploymentId(createId()) : r.deploymentId); // , r.createdBy);
    d.resourceGroupId = r.resourceGroupId;
    d.configurationId = r.configurationId;
    d.scenarioId = conf.scenarioId;
    d.executableId = conf.executableId;
    d.status = DeploymentStatus.pending;
    d.statusMessage = "Deployment created and pending";
    d.ttl = r.ttl;

    deployments.save(d);
    return UsecaseResult(true, d.id.value, "");
  }

  UsecaseResult patchDeployment(PatchDeploymentRequest request) {
    auto d = deployments.findById(request.tenantId, request.resourceGroupId, request.deploymentId);
    if (d.isNull)
      return UsecaseResult(false, "", "Deployment not found");

    if (request.targetStatus.length > 0) {
      TargetStatus target;
      if (request.targetStatus == "stopped")
        target = TargetStatus.stopped;
      else if (request.targetStatus == "running")
        target = TargetStatus.running;
      else if (request.targetStatus == "deleted")
        target = TargetStatus.deleted_;
      else
        return UsecaseResult(false, "", "Invalid target status");

      if (!ExecutionScheduler.canTransitionDeployment(d.status, target))
        return UsecaseResult(false, "", "Cannot transition to target status from current status");

      d.targetStatus = target;
      if (target == TargetStatus.stopped)
        d.status = DeploymentStatus.stopped;
      else if (target == TargetStatus.running)
        d.status = DeploymentStatus.running;
      else if (target == TargetStatus.deleted_)
        d.status = DeploymentStatus.dead;
    }

    // Support configuration update for running deployments
    if (!request.configurationId.isEmpty)
      d.configurationId = request.configurationId;

    if (request.ttl > 0)
      d.ttl = request.ttl;

    
    d.updatedAt = currentTimestamp;

    deployments.update(d);
    return UsecaseResult(true, d.id.value, "");
  }

  Deployment getDeployment(TenantId tenantId, ResourceGroupId rgId, DeploymentId deploymentId) {
    return deployments.findById(tenantId, rgId, deploymentId);
  }

  Deployment[] listDeployments(TenantId tenantId, ResourceGroupId rgId) {
    return deployments.findByResourceGroup(tenantId, rgId);
  }

  Deployment[] listDeployments(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return deployments.findByScenario(tenantId, rgId, scenarioId);
  }

  Deployment[] listDeployments(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status) {
    return deployments.findByStatus(tenantId, rgId, status);
  }

  UsecaseResult deleteDeployment(TenantId tenantId, ResourceGroupId rgId, DeploymentId deploymentId) {
    auto entity = deployments.findById(tenantId, rgId, deploymentId);
    if (entity.isNull)
      return UsecaseResult(false, "", "Deployment not found");

    deployments.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  size_t count(TenantId tenantId, ResourceGroupId rgId) {
    return deployments.countByResourceGroup(tenantId, rgId);
  }
}

///
unittest {
//    auto deploymentRepository = new DeploymentRepository();
//    auto configurationRepository = new ConfigurationRepository();
//    auto usecase = new ManageDeploymentsUseCase(deploymentRepository, configurationRepository);
//    auto tenantId = TenantId("test-tenant");
//
//    assert(usecase !is null);
}
