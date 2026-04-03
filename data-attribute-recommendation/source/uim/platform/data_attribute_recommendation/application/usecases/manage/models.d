module application.usecases.manage_models;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.model_configuration;
import domain.entities.training_job;
import domain.ports.model_config_repository;
import domain.ports.dataset_repository;
import domain.services.model_trainer;
import application.dto;

class ManageModelsUseCase
{
  private ModelConfigRepository repo;
  private DatasetRepository datasetRepo;
  private ModelTrainer trainer;

  this(ModelConfigRepository repo, DatasetRepository datasetRepo, ModelTrainer trainer)
  {
    this.repo = repo;
    this.datasetRepo = datasetRepo;
    this.trainer = trainer;
  }

  CommandResult createModelConfig(CreateModelConfigRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.datasetId.length == 0)
      return CommandResult("", "Dataset ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Model name is required");

    // Verify dataset exists
    auto ds = datasetRepo.findById(req.datasetId, req.tenantId);
    if (ds is null)
      return CommandResult("", "Dataset not found");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Model configuration with this name already exists");

    auto now = Clock.currStdTime();
    auto config = ModelConfiguration();
    config.id = randomUUID().toString();
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

  ModelConfiguration* getModelConfig(ModelConfigId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  ModelConfiguration[] listModelConfigs(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateModelConfig(UpdateModelConfigRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Model configuration ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Model configuration not found");

    if (existing.status != ModelConfigStatus.draft)
      return CommandResult("", "Only draft configurations can be updated");

    auto updated = *existing;
    if (req.name.length > 0) updated.name = req.name;
    if (req.description.length > 0) updated.description = req.description;
    if (req.targetColumns.length > 0) updated.targetColumns = req.targetColumns;
    if (req.featureColumns.length > 0) updated.featureColumns = req.featureColumns;
    if (req.hyperparameters.length > 0) updated.hyperparameters = req.hyperparameters;
    updated.modelType = req.modelType;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Mark a model configuration as ready for training.
  CommandResult activateConfig(ModelConfigId id, TenantId tenantId)
  {
    auto config = repo.findById(id, tenantId);
    if (config is null)
      return CommandResult("", "Model configuration not found");

    if (config.status != ModelConfigStatus.draft)
      return CommandResult("", "Only draft configurations can be activated");

    if (config.targetColumns.length == 0 || config.featureColumns.length == 0)
      return CommandResult("", "Target and feature columns must be defined");

    config.status = ModelConfigStatus.ready;
    config.updatedAt = Clock.currStdTime();
    repo.update(*config);
    return CommandResult(id, "");
  }

  /// Start training on a model configuration.
  CommandResult startTraining(StartTrainingRequest req)
  {
    if (req.modelConfigId.length == 0)
      return CommandResult("", "Model configuration ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto job = trainer.startTraining(req.modelConfigId, req.tenantId, req.createdBy);
    if (job is null)
      return CommandResult("", "Cannot start training - verify dataset is completed and config is ready");

    return CommandResult(job.id, "");
  }

  CommandResult deleteModelConfig(ModelConfigId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Model configuration not found");

    if (existing.status == ModelConfigStatus.training)
      return CommandResult("", "Cannot delete a configuration that is currently training");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
