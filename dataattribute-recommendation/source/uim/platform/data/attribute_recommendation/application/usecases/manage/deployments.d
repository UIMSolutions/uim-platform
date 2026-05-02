/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.application.usecases.manage.deployments;

// import std.uuid;
// import std.conv : to;
// import std.datetime.systime : Clock;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_deployment;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.deployments;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.training_jobs;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.model_configs;
import uim.platform.data.attribute_recommendation.application.dto;

class ManageDeploymentsUseCase { // TODO: UIMUseCase {
  private DeploymentRepository repo;
  private TrainingJobRepository jobRepo;
  private ModelConfigRepository configRepo;

  this(DeploymentRepository repo, TrainingJobRepository jobRepo, ModelConfigRepository configRepo) {
    this.repo = repo;
    this.jobRepo = jobRepo;
    this.configRepo = configRepo;
  }

  CommandResult createDeployment(CreateDeploymentRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.trainingJobId.isEmpty)
      return CommandResult(false, "", "Training job ID is required");

    // Verify training job completed successfully
    auto job = jobRepo.findById(req.trainingJobId, req.tenantId);
    if (job.isNull)
      return CommandResult(false, "", "Training job not found");
    if (job.status != JobStatus.completed)
      return CommandResult(false, "", "Training job must be completed before deployment");

    // Check no active deployment exists for this job
    auto existingDep = repo.findByTrainingJob(req.trainingJobId, req.tenantId);
    if (existingDep !is null && existingDep.status == DeploymentStatus.active)
      return CommandResult(false, "", "An active deployment already exists for this training job");

    auto now = Clock.currStdTime();
    auto dep = ModelDeployment();
    dep.id = randomUUID();
    dep.tenantId = req.tenantId;
    dep.trainingJobId = req.trainingJobId;
    dep.modelConfigId = job.modelConfigId;
    dep.name = req.name.length > 0 ? req.name : "deployment-" ~ dep.id[0 .. 8];
    dep.status = DeploymentStatus.deploying;
    dep.endpointUrl = "/api/v1/inference/" ~ dep.id;
    dep.version_ = "1.0";
    dep.replicas = req.replicas > 0 ? req.replicas : 1;
    dep.createdBy = req.createdBy;
    dep.createdAt = now;
    dep.updatedAt = now;

    repo.save(dep);

    // Simulate immediate activation
    activateDeployment(dep.id, req.tenantId);

    return CommandResult(dep.id, "");
  }

  ModelDeployment* getDeployment(DeploymentId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  ModelDeployment[] listDeployments(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  /// Activate a deploying or inactive deployment.
  CommandResult activateDeployment(DeploymentId tenantId, id tenantId) {
    auto dep = repo.findById(tenantId, id);
    if (dep.isNull)
      return CommandResult(false, "", "Deployment not found");

    if (dep.status != DeploymentStatus.deploying && dep.status != DeploymentStatus.inactive)
      return CommandResult(false, "", "Deployment cannot be activated from current state");

    dep.status = DeploymentStatus.active;
    dep.updatedAt = Clock.currStdTime();
    repo.update(dep);
    return CommandResult(true, id.value, "");
  }

  /// Deactivate an active deployment.
  CommandResult deactivateDeployment(DeploymentId tenantId, id tenantId) {
    auto dep = repo.findById(tenantId, id);
    if (dep.isNull)
      return CommandResult(false, "", "Deployment not found");

    if (dep.status != DeploymentStatus.active)
      return CommandResult(false, "", "Only active deployments can be deactivated");

    dep.status = DeploymentStatus.inactive;
    dep.updatedAt = Clock.currStdTime();
    repo.update(dep);
    return CommandResult(true, id.value, "");
  }

  CommandResult deleteDeployment(DeploymentId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Deployment not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
