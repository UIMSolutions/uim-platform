/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.application.usecases.monitor_training;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;
import uim.platform.data.attribute_recommendation.domain.entities.model_deployment;
import uim.platform.data.attribute_recommendation.domain.entities.model_configuration;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.training_jobs;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.deployments;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.model_configs;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.inference_requests;

/// Read-only summaries for training jobs, deployments, and overall pipeline health.
struct TrainingJobSummary {
  TrainingJobId jobId;
  ModelConfigId modelConfigId;
  string modelName;
  JobStatus status;
  string metrics;
  int epochsCompleted;
  int totalEpochs;
  long startedAt;
  long completedAt;
}

struct DeploymentSummary {
  DeploymentId deploymentId;
  string deploymentName;
  DeploymentStatus status;
  string modelName;
  string version_;
  int replicas;
  long inferenceCount;
}

struct PipelineSummary {
  int totalModels;
  int trainedModels;
  int activeDeployments;
  int totalTrainingJobs;
  int completedJobs;
  int failedJobs;
  long totalInferenceRequests;
}

class MonitorTrainingUseCase : UIMUseCase {
  private TrainingJobRepository jobRepo;
  private DeploymentRepository deploymentRepo;
  private ModelConfigRepository configRepo;
  private InferenceRequestRepository inferenceRepo;

  this(TrainingJobRepository jobRepo, DeploymentRepository deploymentRepo,
      ModelConfigRepository configRepo, InferenceRequestRepository inferenceRepo)
  {
    this.jobRepo = jobRepo;
    this.deploymentRepo = deploymentRepo;
    this.configRepo = configRepo;
    this.inferenceRepo = inferenceRepo;
  }

  TrainingJobSummary[] listTrainingJobs(TenantId tenantId)
  {
    auto jobs = jobRepo.findByTenant(tenantId);
    TrainingJobSummary[] result;
    foreach (ref job; jobs)
      result ~= buildJobSummary(job, tenantId);
    return result;
  }

  TrainingJobSummary getTrainingJob(TrainingJobId id, TenantId tenantId)
  {
    auto job = jobRepo.findById(id, tenantId);
    if (job is null)
      return TrainingJobSummary.init;
    return buildJobSummary(*job, tenantId);
  }

  DeploymentSummary[] listDeploymentSummaries(TenantId tenantId)
  {
    auto deps = deploymentRepo.findByTenant(tenantId);
    DeploymentSummary[] result;
    foreach (ref dep; deps)
      result ~= buildDeploymentSummary(dep, tenantId);
    return result;
  }

  PipelineSummary getPipelineSummary(TenantId tenantId)
  {
    PipelineSummary s;

    auto configs = configRepo.findByTenant(tenantId);
    s.totalModels = cast(int) configs.length;
    foreach (ref c; configs)
      if (c.status == ModelConfigStatus.trained)
        s.trainedModels++;

    auto deps = deploymentRepo.findByTenant(tenantId);
    foreach (ref d; deps)
      if (d.status == DeploymentStatus.active)
        s.activeDeployments++;

    auto jobs = jobRepo.findByTenant(tenantId);
    s.totalTrainingJobs = cast(int) jobs.length;
    foreach (ref j; jobs)
    {
      if (j.status == JobStatus.completed)
        s.completedJobs++;
      else if (j.status == JobStatus.failed)
        s.failedJobs++;
    }

    auto inferences = inferenceRepo.findByTenant(tenantId);
    s.totalInferenceRequests = cast(long) inferences.length;

    return s;
  }

  private TrainingJobSummary buildJobSummary(ref TrainingJob job, TenantId tenantId)
  {
    TrainingJobSummary s;
    s.jobId = job.id;
    s.modelConfigId = job.modelConfigId;
    s.status = job.status;
    s.metrics = job.metrics;
    s.epochsCompleted = job.epochsCompleted;
    s.totalEpochs = job.totalEpochs;
    s.startedAt = job.startedAt;
    s.completedAt = job.completedAt;

    auto config = configRepo.findById(job.modelConfigId, tenantId);
    if (config !is null)
      s.modelName = config.name;

    return s;
  }

  private DeploymentSummary buildDeploymentSummary(ref ModelDeployment dep, TenantId tenantId)
  {
    DeploymentSummary s;
    s.deploymentId = dep.id;
    s.deploymentName = dep.name;
    s.status = dep.status;
    s.version_ = dep.version_;
    s.replicas = dep.replicas;

    auto config = configRepo.findById(dep.modelConfigId, tenantId);
    if (config !is null)
      s.modelName = config.name;

    auto reqs = inferenceRepo.findByDeployment(dep.id, tenantId);
    s.inferenceCount = cast(long) reqs.length;

    return s;
  }
}
