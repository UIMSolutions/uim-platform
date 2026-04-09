/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.services.model_trainer;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.dataset;
import uim.platform.data.attribute_recommendation.domain.entities.model_configuration;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.model_configs;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.training_jobs;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.data_records;

/// Domain service that orchestrates the training lifecycle:
/// validates dataset readiness, creates training jobs, and
/// simulates training with quality metrics.
class ModelTrainer {
  private DatasetRepository datasetRepo;
  private ModelConfigRepository configRepo;
  private TrainingJobRepository jobRepo;
  private DataRecordRepository recordRepo;

  this(DatasetRepository datasetRepo, ModelConfigRepository configRepo,
      TrainingJobRepository jobRepo, DataRecordRepository recordRepo) {
    this.datasetRepo = datasetRepo;
    this.configRepo = configRepo;
    this.jobRepo = jobRepo;
    this.recordRepo = recordRepo;
  }

  /// Validate that a model configuration can be trained.
  bool canTrain(ModelConfigId configId, TenantId tenantId) {
    auto config = configRepo.findById(configId, tenantId);
    if (config is null)
      return false;
    if (config.status != ModelConfigStatus.ready && config.status != ModelConfigStatus.trained)
      return false;

    auto ds = datasetRepo.findById(config.datasetId, tenantId);
    if (ds is null)
      return false;
    if (ds.status != DatasetStatus.completed)
      return false;

    auto recordCount = recordRepo.countByDataset(ds.id, tenantId);
    return recordCount > 0;
  }

  /// Start a training job for the given model configuration.
  TrainingJob* startTraining(ModelConfigId configId, TenantId tenantId, UserId userId) {
    if (!canTrain(configId, tenantId))
      return null;

    auto config = configRepo.findById(configId, tenantId);
    auto now = Clock.currStdTime();

    // Update config status to training
    config.status = ModelConfigStatus.training;
    config.updatedAt = now;
    configRepo.update(*config);

    // Create training job
    auto job = TrainingJob();
    job.id = randomUUID();
    job.tenantId = tenantId;
    job.modelConfigId = configId;
    job.status = JobStatus.running;
    job.totalEpochs = 10;
    job.startedAt = now;
    job.createdBy = userId;
    job.createdAt = now;

    jobRepo.save(job);

    // Simulate immediate training completion with metrics
    completeTraining(job.id, tenantId);

    return jobRepo.findById(job.id, tenantId);
  }

  /// Simulate training completion with generated quality metrics.
  void completeTraining(TrainingJobId jobId, TenantId tenantId) {
    auto job = jobRepo.findById(jobId, tenantId);
    if (job is null)
      return;

    auto now = Clock.currStdTime();
    job.status = JobStatus.completed;
    job.epochsCompleted = job.totalEpochs;
    job.completedAt = now;
    job.metrics = `{"accuracy":0.92,"precision":0.89,"recall":0.91,"f1Score":0.90}`;

    jobRepo.update(*job);

    // Update model config to trained
    auto config = configRepo.findById(job.modelConfigId, tenantId);
    if (config !is null) {
      config.status = ModelConfigStatus.trained;
      config.updatedAt = now;
      configRepo.update(*config);
    }
  }

  /// Cancel a running training job.
  bool cancelTraining(TrainingJobId jobId, TenantId tenantId) {
    auto job = jobRepo.findById(jobId, tenantId);
    if (job is null || job.status != JobStatus.running)
      return false;

    auto now = Clock.currStdTime();
    job.status = JobStatus.cancelled;
    job.completedAt = now;
    jobRepo.update(*job);

    // Revert config status
    auto config = configRepo.findById(job.modelConfigId, tenantId);
    if (config !is null) {
      config.status = ModelConfigStatus.ready;
      config.updatedAt = now;
      configRepo.update(*config);
    }
    return true;
  }
}
