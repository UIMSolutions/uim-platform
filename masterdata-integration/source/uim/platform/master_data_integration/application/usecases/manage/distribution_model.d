/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.distribution_model;

// import uim.platform.master_data_integration.domain.entities.distribution_model;
// import uim.platform.master_data_integration.domain.ports.repositories.distribution_models;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
/// Application service for distribution model management.
class ManageDistributionModelsUseCase { // TODO: UIMUseCase {
  private DistributionModelRepository repo;

  this(DistributionModelRepository repo) {
    this.repo = repo;
  }

  CommandResult createModel(CreateDistributionModelRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Distribution model name is required");

    if (req.sourceClientId.isEmpty)
      return CommandResult(false, "", "Source client ID is required");

    auto model = DistributionModel(req.tenantId); //, UserId("test-user"));
    model.name = req.name;
    model.description = req.description;
    model.status = DistributionModelStatus.draft;
    model.direction = toDistributionDirection(req.direction);
    model.sourceClientId = req.sourceClientId;
    model.targetClientIds = req.targetClientIds;
    model.categories = toMasterDataCategories(req.categories);
    model.dataModelIds = req.dataModelIds;
    model.filterRuleIds = req.filterRuleIds;
    model.autoReplicate = req.autoReplicate;
    model.cronSchedule = req.cronSchedule;

    repo.save(model);
    return CommandResult(true, model.id.value, "");
  }

  CommandResult updateModel(UpdateDistributionModelRequest req) {
    auto model = repo.findById(req.tenantId, req.modelId);
    if (model.isNull)
      return CommandResult(false, "", "Distribution model not found");

    if (req.name.length > 0)
      model.name = req.name;
    if (req.description.length > 0)
      model.description = req.description;
    if (req.status.length > 0)
      model.status = toDistributionModelStatus(req.status);
    if (req.targetClientIds.length > 0)
      model.targetClientIds = req.targetClientIds;
    // TODO:
    // if (req.categories.length > 0)
    //   model.categories = toMasterDataCategory(req.categories);
    if (req.dataModelIds.length > 0)
      model.dataModelIds = req.dataModelIds;
    if (req.filterRuleIds.length > 0)
      model.filterRuleIds = req.filterRuleIds;
    model.autoReplicate = req.autoReplicate;
    if (req.cronSchedule.length > 0)
      model.cronSchedule = req.cronSchedule;
    model.updatedAt = clockSeconds();

    repo.update(model);
    return CommandResult(true, model.id.value, "");
  }

  CommandResult activateModel(TenantId tenantId, DistributionModelId id) {
    auto model = repo.findById(tenantId, id);
    if (model.isNull)
      return CommandResult(false, "", "Distribution model not found");
    model.status = DistributionModelStatus.active;
    model.updatedAt = clockSeconds();
    repo.update(model);
    return CommandResult(true, model.id.value, "");
  }

  CommandResult deactivateModel(TenantId tenantId, DistributionModelId id) {
    auto model = repo.findById(tenantId, id);
    if (model.isNull)
      return CommandResult(false, "", "Distribution model not found");
    model.status = DistributionModelStatus.inactive;
    model.updatedAt = clockSeconds();
    repo.update(model);
    return CommandResult(true, model.id.value, "");
  }

  DistributionModel getModel(TenantId tenantId, DistributionModelId id) {
    return repo.findById(tenantId, id);
  }

  DistributionModel[] listModels(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DistributionModel[] listModels(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, toDistributionModelStatus(status));
  }

  CommandResult deleteModel(TenantId tenantId, DistributionModelId id) {
    auto model = repo.findById(tenantId, id);
    if (model.isNull)
      return CommandResult(false, "", "Distribution model not found");

    repo.remove(model);
    return CommandResult(true, model.id.value, "");
  }
}


