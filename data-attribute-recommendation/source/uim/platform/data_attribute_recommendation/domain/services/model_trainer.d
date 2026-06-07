/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.services.model_trainer;



// import uim.platform.data_attribute_recommendation.domain.entities.model_configuration;
// import uim.platform.data_attribute_recommendation.domain.entities.training_job;

// import uim.platform.data_attribute_recommendation.domain.ports.repositories.model_configs;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.training_jobs;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.data_records;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:

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
  bool canTrain(TenantId tenantId, ModelConfigId configId) {
    auto config = configRepo.findById(tenantId, configId);
    if (config.isNull)
      return false;
    if (config.status != ModelConfigStatus.ready && config.status != ModelConfigStatus.trained)
      return false;

    auto ds = datasetRepo.findById(tenantId, config.datasetId);
    if (ds.isNull)
      return false;
    if (ds.status != DatasetStatus.completed)
      return false;

    auto recordCount = recordRepo.countByDataset(tenantId, ds.id);
    return recordCount > 0;
  }

  /// Start a training job for the given model configuration.
  TrainingJob startTraining(TenantId tenantId, ModelConfigId configId, UserId userId) {
    if (!canTrain(tenantId, configId))
      return null;

    auto config = configRepo.findById(tenantId, configId);
    auto now = currentTimestamp();

    // Update config status to training
    config.status = ModelConfigStatus.training;
    config.updatedAt = now;
    configRepo.update(config);

    // Create training job
    TrainingJob job;
    job.initEntity(tenantId, userId);

    job.modelConfigId = configId;
    job.status = JobStatus.running;
    job.totalEpochs = 10;
    job.startedAt = job.createdAt;

    jobRepo.save(job);
    // Simulate immediate training completion with metrics
    completeTraining(tenantId, job.id);

    return jobRepo.findById(tenantId, job.id);
  }

  /// Simulate training completion with generated quality metrics.
  void completeTraining(TenantId tenantId, TrainingJobId jobId) {
    auto job = jobRepo.findById(tenantId, jobId);
    if (job.isNull)
      return;

    auto now = currentTimestamp();
    job.status = JobStatus.completed;
    job.epochsCompleted = job.totalEpochs;
    job.completedAt = now;
    job.metrics = `{"accuracy":0.92,"precision":0.89,"recall":0.91,"f1Score":0.90}`;

    jobRepo.update(job);

    // Update model config to trained
    auto config = configRepo.findById(tenantId, job.modelConfigId);
    if (!config.isNull) {
      config.status = ModelConfigStatus.trained;
      config.updatedAt = now;
      configRepo.update(config);
    }
  }

  /// Cancel a running training job.
  bool cancelTraining(TenantId tenantId, TrainingJobId jobId) {
    auto job = jobRepo.findById(tenantId, jobId);
    if (job.isNull || job.status != JobStatus.running)
      return false;

    auto now = currentTimestamp();
    job.status = JobStatus.cancelled;
    job.completedAt = now;
    jobRepo.update(job);

    // Revert config status
    auto config = configRepo.findById(tenantId, job.modelConfigId);
    if (!config.isNull) {
      config.status = ModelConfigStatus.ready;
      config.updatedAt = now;
      configRepo.update(config);
    }
    return true;
  }
}
