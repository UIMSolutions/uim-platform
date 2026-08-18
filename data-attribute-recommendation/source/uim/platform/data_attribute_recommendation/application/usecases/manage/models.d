/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.application.usecases.manage.models;

// import uim.platform.data_attribute_recommendation.domain.entities.model_configuration;
// import uim.platform.data_attribute_recommendation.domain.entities.training_job;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.model_configs;

// import uim.platform.data_attribute_recommendation.domain.services.model_trainer;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class ManageModelsUseCase {
  protected IModelConfigRepository repo;
  private IDatasetRepository datasetRepo;
  private ModelTrainer trainer;

  this(IModelConfigRepository repo, IDatasetRepository datasetRepo, ModelTrainer trainer) {
    this.repo = repo;
    this.datasetRepo = datasetRepo;
    this.trainer = trainer;
  }

  UsecaseResult createModelConfig(CreateModelConfigRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.datasetId.isEmpty)
      return UsecaseResult(false, "", "Dataset ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Model name is required");

    // Verify dataset exists
    auto ds = datasetRepo.findById(req.tenantId, req.datasetId);
    if (ds.isNull)
      return UsecaseResult(false, "", "Dataset not found");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Model configuration with this name already exists");

    auto config = ModelConfiguration(req.tenantId, req.configId.isNull ? ModelConfigurationId(createId()) : req.configId, req.createdBy); 
    config.datasetId = req.datasetId;
    config.name = req.name;
    config.description = req.description;
    config.modelType = req.modelType.toModelType;
    config.targetColumns = req.targetColumns;
    config.featureColumns = req.featureColumns;
    config.hyperparameters = req.hyperparameters;
    config.status = ModelConfigStatus.draft;
 
    repo.save(config);
    return UsecaseResult(true, config.id.value, "");
  }

  ModelConfiguration getModelConfig(TenantId tenantId, ModelConfigurationId id) {
    return repo.findById(tenantId, id);
  }

  ModelConfiguration[] listModelConfigs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateModelConfig(UpdateModelConfigRequest req) {
    if (req.configId.isNull)
      return UsecaseResult(false, "", "Model configuration ID is required");
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.configId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Model configuration not found");

    if (existing.status != ModelConfigStatus.draft)
      return UsecaseResult(false, "", "Only draft configurations can be updated");

    auto updated = existing;
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
    updated.modelType = req.modelType.toModelType;
    updated.updatedAt = currentTimestamp();

    repo.update(updated);
    return UsecaseResult(true, updated.id.value, "");
  }

  /// Mark a model configuration as ready for training.
  UsecaseResult activateConfig(TenantId tenantId, ModelConfigurationId id) {
    auto config = repo.findById(tenantId, id);
    if (config.isNull)
      return UsecaseResult(false, "", "Model configuration not found");

    if (config.status != ModelConfigStatus.draft)
      return UsecaseResult(false, "", "Only draft configurations can be activated");

    if (config.targetColumns.length == 0 || config.featureColumns.length == 0)
      return UsecaseResult(false, "", "Target and feature columns must be defined");

    config.status = ModelConfigStatus.ready;
    config.updatedAt = currentTimestamp();
    
    repo.update(config);
    return UsecaseResult(true, config.id.value, "");
  }

  /// Start training on a model configuration.
  UsecaseResult startTraining(StartTrainingRequest req) {
    if (req.configId.isEmpty)
      return UsecaseResult(false, "", "Model configuration ID is required");
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto job = trainer.startTraining(req.tenantId, req.configId, req.createdBy);
    if (job.isNull)
      return UsecaseResult(false, "", "Cannot start training - verify dataset is completed and config is ready");

    return UsecaseResult(true, job.id.value, "");
  }

  UsecaseResult deleteModelConfig(TenantId tenantId, ModelConfigurationId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Model configuration not found");

    if (existing.status == ModelConfigStatus.training)
      return UsecaseResult(false, "", "Cannot delete a configuration that is currently training");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
    auto iModelConfigRepository = new IModelConfigRepository();
    auto iDatasetRepository = new IDatasetRepository();
    auto modelTrainer = new ModelTrainer();
    auto usecase = new ManageModelsUseCase(iModelConfigRepository, iDatasetRepository, modelTrainer);
    auto tenantId = TenantId("test-tenant");

    // Test list
    auto items = usecase.listModelConfigs(tenantId);
    assert(items !is null);

}
