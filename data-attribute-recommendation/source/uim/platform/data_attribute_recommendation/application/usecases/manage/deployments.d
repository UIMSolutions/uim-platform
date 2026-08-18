/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.application.usecases.manage.deployments;

// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
// import uim.platform.data_attribute_recommendation.domain.entities.training_job;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.deployments;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.training_jobs;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.model_configs;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class ManageDeploymentsUseCase {
  protected IDeploymentRepository repo;
  private ITrainingJobRepository jobRepo;
  private IModelConfigRepository configRepo;

  this(IDeploymentRepository repo, ITrainingJobRepository jobRepo, IModelConfigRepository configRepo) {
    this.repo = repo;
    this.jobRepo = jobRepo;
    this.configRepo = configRepo;
  }

  UsecaseResult createDeployment(CreateDeploymentRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.jobId.isEmpty)
      return UsecaseResult(false, "", "Training job ID is required");

    // Verify training job completed successfully
    auto job = jobRepo.findById(req.tenantId, req.jobId);
    if (job.isNull)
      return UsecaseResult(false, "", "Training job not found");
    if (job.status != JobStatus.completed)
      return UsecaseResult(false, "", "Training job must be completed before deployment");

    // Check no active deployment exists for this job
    auto existingDep = repo.findByTrainingJob(req.tenantId, req.jobId);
    if (!existingDep.isNull && existingDep.status == DeploymentStatus.active)
      return UsecaseResult(false, "", "An active deployment already exists for this training job");

    auto dep = ModelDeployment(req.tenantId);
    dep.trainingJobId = req.jobId;
    dep.modelConfigId = job.modelConfigId;
    dep.name = req.name.length > 0 ? req.name : "deployment-" ~ dep.id.value[0 .. 8];
    dep.status = DeploymentStatus.deploying;
    dep.endpointUrl = "/api/v1/inference/" ~ dep.id.value;
    dep.version_ = "1.0";
    dep.replicas = req.replicas > 0 ? req.replicas : 1;

    repo.save(dep);

    // Simulate immediate activation
    activateDeployment(req.tenantId, dep.id);

    return UsecaseResult(true, dep.id.value, "");
  }

  ModelDeployment getDeployment(TenantId tenantId, DeploymentId id) {
    return repo.findById(tenantId, id);
  }

  ModelDeployment[] listDeployments(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  /// Activate a deploying or inactive deployment.
  UsecaseResult activateDeployment(TenantId tenantId, DeploymentId id) {
    auto dep = repo.findById(tenantId, id);
    if (dep.isNull)
      return UsecaseResult(false, "", "Deployment not found");

    if (dep.status != DeploymentStatus.deploying && dep.status != DeploymentStatus.inactive)
      return UsecaseResult(false, "", "Deployment cannot be activated from current state");

    dep.status = DeploymentStatus.active;
    dep.updatedAt = currentTimestamp();
    repo.update(dep);
    return UsecaseResult(true, dep.id.value, "");
  }

  /// Deactivate an active deployment.
  UsecaseResult deactivateDeployment(TenantId tenantId, DeploymentId id) {
    auto dep = repo.findById(tenantId, id);
    if (dep.isNull)
      return UsecaseResult(false, "", "Deployment not found");

    if (dep.status != DeploymentStatus.active)
      return UsecaseResult(false, "", "Only active deployments can be deactivated");

    dep.status = DeploymentStatus.inactive;
    dep.updatedAt = currentTimestamp();
    repo.update(dep);
    return UsecaseResult(true, dep.id.value, "");
  }

  UsecaseResult deleteDeployment(TenantId tenantId, DeploymentId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Deployment not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
    auto iDeploymentRepository = new IDeploymentRepository();
    auto iTrainingJobRepository = new ITrainingJobRepository();
    auto iModelConfigRepository = new IModelConfigRepository();
    auto usecase = new ManageDeploymentsUseCase(iDeploymentRepository, iTrainingJobRepository, iModelConfigRepository);
    auto tenantId = TenantId("test-tenant");

    // Test list
    auto items = usecase.listDeployments(tenantId);
    assert(items !is null);

}
