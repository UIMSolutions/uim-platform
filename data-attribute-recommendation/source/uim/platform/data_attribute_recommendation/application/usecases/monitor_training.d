/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.application.usecases.monitor_training;

// import uim.platform.data_attribute_recommendation.domain.entities.training_job;
// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
// import uim.platform.data_attribute_recommendation.domain.entities.model_configuration;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.training_jobs;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.deployments;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.model_configs;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.inference_requests;

import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
/// Read-only summaries for training jobs, deployments, and overall pipeline health.
struct TrainingJobSummary {
  TenantId tenantId;
  TrainingJobId jobId;
  ModelConfigurationId modelConfigId;
  string modelName;
  JobStatus status;
  string metrics;
  int epochsCompleted;
  int totalEpochs;
  long startedAt;
  long completedAt;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("jobId", jobId)
      .set("modelConfigId", modelConfigId)
      .set("modelName", modelName)
      .set("status", status.to!string)
      .set("metrics", metrics)
      .set("epochsCompleted", epochsCompleted)
      .set("totalEpochs", totalEpochs)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt);
  }
}

struct DeploymentSummary {
  DeploymentId deploymentId;
  string deploymentName;
  DeploymentStatus status;
  string modelName;
  string version_;
  int replicas;
  long inferenceCount;

  Json toJson() const {
    return Json.emptyObject
      .set("deploymentId", deploymentId)
      .set("deploymentName", deploymentName)
      .set("status", status.to!string)
      .set("modelName", modelName)
      .set("version", version_)
      .set("replicas", replicas)
      .set("inferenceCount", inferenceCount);
  }
}

struct PipelineSummary {
  int totalModels;
  int trainedModels;
  int activeDeployments;
  int totalTrainingJobs;
  int completedJobs;
  int failedJobs;
  long totalInferenceRequests;

  Json toJson() const {
    return Json.emptyObject
      .set("totalModels", totalModels)
      .set("trainedModels", trainedModels)
      .set("activeDeployments", activeDeployments)
      .set("totalTrainingJobs", totalTrainingJobs)
      .set("completedJobs", completedJobs)
      .set("failedJobs", failedJobs)
      .set("totalInferenceRequests", totalInferenceRequests);
  }
}

class MonitorTrainingUseCase { // TODO: UIMUseCase {
  private TrainingJobRepository jobRepo;
  private DeploymentRepository deploymentRepo;
  private ModelConfigRepository configRepo;
  private InferenceRequestRepository inferenceRepo;

  this(TrainingJobRepository jobRepo, DeploymentRepository deploymentRepo,
    ModelConfigRepository configRepo, InferenceRequestRepository inferenceRepo) {
    this.jobRepo = jobRepo;
    this.deploymentRepo = deploymentRepo;
    this.configRepo = configRepo;
    this.inferenceRepo = inferenceRepo;
  }

  TrainingJobSummary[] listTrainingJobs(TenantId tenantId) {
    auto jobs = jobRepo.find(tenantId);
    TrainingJobSummary[] result;
    foreach (job; jobs)
      result ~= buildJobSummary(job);
    return result;
  }

  TrainingJobSummary getTrainingJob(TenantId tenantId, TrainingJobId id) {
    auto job = jobRepo.findById(tenantId, id);
    if (job.isNull)
      return TrainingJobSummary.init;
    return buildJobSummary(job);
  }

  DeploymentSummary[] listDeploymentSummaries(TenantId tenantId) {
    auto deps = deploymentRepo.find(tenantId);
    DeploymentSummary[] result;
    foreach (d; deps)
      result ~= buildDeploymentSummary(d);
    return result;
  }

  PipelineSummary getPipelineSummary(TenantId tenantId) {
    PipelineSummary s;

    auto configs = configRepo.find(tenantId);
    s.totalModels = cast(int)configs.length;
    foreach (c; configs)
      if (c.status == ModelConfigStatus.trained)
        s.trainedModels++;

    auto deps = deploymentRepo.find(tenantId);
    foreach (d; deps)
      if (d.status == DeploymentStatus.active)
        s.activeDeployments++;

    auto jobs = jobRepo.find(tenantId);
    s.totalTrainingJobs = cast(int)jobs.length;
    foreach (j; jobs) {
      if (j.status == JobStatus.completed)
        s.completedJobs++;
      else if (j.status == JobStatus.failed)
        s.failedJobs++;
    }

    auto inferences = inferenceRepo.find(tenantId);
    s.totalInferenceRequests = inferences.length;

    return s;
  }

  private TrainingJobSummary buildJobSummary(TrainingJob job) {
    TrainingJobSummary s;
    s.tenantId = job.tenantId;
    s.jobId = job.id;
    s.modelConfigId = job.modelConfigId;
    s.status = job.status;
    s.metrics = job.metrics;
    s.epochsCompleted = job.epochsCompleted;
    s.totalEpochs = job.totalEpochs;
    s.startedAt = job.startedAt;
    s.completedAt = job.completedAt;

    auto config = configRepo.findById(job.tenantId, job.modelConfigId);
    if (!config.isNull)
      s.modelName = config.name;

    return s;
  }

  private DeploymentSummary buildDeploymentSummary(ModelDeployment dep) {
    DeploymentSummary s;
    s.deploymentId = dep.id;
    s.deploymentName = dep.name;
    s.status = dep.status;
    s.version_ = dep.version_;
    s.replicas = dep.replicas;

    auto config = configRepo.findById(dep.tenantId, dep.modelConfigId);
    if (!config.isNull)
      s.modelName = config.name;

    auto reqs = inferenceRepo.findByDeployment(dep.tenantId, dep.id);
    s.inferenceCount = reqs.length;

    return s;
  }
}
