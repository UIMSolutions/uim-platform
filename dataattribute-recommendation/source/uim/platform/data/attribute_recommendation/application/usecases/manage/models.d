/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.application.usecases.manage.models;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_configuration;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.model_configs;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;
import uim.platform.data.attribute_recommendation.domain.services.model_trainer;
import uim.platform.data.attribute_recommendation.application.dto;

class ManageModelsUseCase { // TODO: UIMUseCase {
  private ModelConfigRepository repo;
  private DatasetRepository datasetRepo;
  private ModelTrainer trainer;

  this(ModelConfigRepository repo, DatasetRepository datasetRepo, ModelTrainer trainer) {
    this.repo = repo;
    this.datasetRepo = datasetRepo;
    this.trainer = trainer;
  }

  CommandResult createModelConfig(CreateModelConfigRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.datasetId.isEmpty)
      return CommandResult(false, "", "Dataset ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Model name is required");

    // Verify dataset exists
    auto ds = datasetRepo.findById(req.datasetId, req.tenantId);
    if (ds.isNull)
      return CommandResult(false, "", "Dataset not found");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult(false, "", "Model configuration with this name already exists");

    auto now = Clock.currStdTime();
    auto config = ModelConfiguration();
    config.id = randomUUID();
    config.tenantId = req.tenantId;
    config.datasetId = req.datasetId;
    config.name = req.name;
    config.description = req.description;
    config.modelType = req.modelType;
    config.targetColumns = req.targetColumns;
    config.featureColumns = req.featureColumns;
    config.hyperparameters = req.hyperparameters;
    config.status = ModelConfigStatus.draft;
    config.createdBy = req.createdBy;
    config.createdAt = now;
    config.updatedAt = now;

    repo.save(config);
    return CommandResult(config.id, "");
  }

  ModelConfiguration* getModelConfig(ModelConfigId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  ModelConfiguration[] listModelConfigs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateModelConfig(UpdateModelConfigRequest req) {
    if (req.id.isEmpty)
      return CommandResult(false, "", "Model configuration ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing.isNull)
      return CommandResult(false, "", "Model configuration not found");

    if (existing.status != ModelConfigStatus.draft)
      return CommandResult(false, "", "Only draft configurations can be updated");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.targetColumns.length > 0)
      updated.targetColumns = req.targetColumns;
    if (req.featureColumns.length > 0)
      updated.featureColumns = req.featureColumns;
    if (req.hyperparameters.length > 0)
      updated.hyperparameters = req.hyperparameters;
    updated.modelType = req.modelType;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Mark a model configuration as ready for training.
  CommandResult activateConfig(ModelConfigId tenantId, id tenantId) {
    auto config = repo.findById(tenantId, id);
    if (config.isNull)
      return CommandResult(false, "", "Model configuration not found");

    if (config.status != ModelConfigStatus.draft)
      return CommandResult(false, "", "Only draft configurations can be activated");

    if (config.targetColumns.length == 0 || config.featureColumns.length == 0)
      return CommandResult(false, "", "Target and feature columns must be defined");

    config.status = ModelConfigStatus.ready;
    config.updatedAt = Clock.currStdTime();
    repo.update(*config);
    return CommandResult(true, id.toString, "");
  }

  /// Start training on a model configuration.
  CommandResult startTraining(StartTrainingRequest req) {
    if (req.modelConfigId.isEmpty)
      return CommandResult(false, "", "Model configuration ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto job = trainer.startTraining(req.modelConfigId, req.tenantId, req.createdBy);
    if (job.isNull)
      return CommandResult("",
          "Cannot start training - verify dataset is completed and config is ready");

    return CommandResult(job.id, "");
  }

  CommandResult deleteModelConfig(ModelConfigId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Model configuration not found");

    if (existing.status == ModelConfigStatus.training)
      return CommandResult(false, "", "Cannot delete a configuration that is currently training");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
