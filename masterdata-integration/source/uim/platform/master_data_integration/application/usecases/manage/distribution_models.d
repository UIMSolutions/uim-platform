/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.distribution_models;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.distribution_model;
import uim.platform.master_data_integration.domain.ports.repositories.distribution_models;
import uim.platform.master_data_integration.domain.types;

/// Application service for distribution model management.
class ManageDistributionModelsUseCase { // TODO: UIMUseCase {
  private DistributionModelRepository repo;

  this(DistributionModelRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDistributionModelRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Distribution model name is required");
    if (req.sourceClientId.isEmpty)
      return CommandResult(false, "", "Source client ID is required");

    DistributionModel model;
    model.id = randomUUID();
    model.tenantId = req.tenantId;
    model.name = req.name;
    model.description = req.description;
    model.status = DistributionModelStatus.draft;
    model.direction = parseDirection(req.direction);
    model.sourceClientId = req.sourceClientId;
    model.targetClientIds = req.targetClientIds;
    model.categories = parseCategories(req.categories);
    model.dataModelIds = req.dataModelIds;
    model.filterRuleIds = req.filterRuleIds;
    model.autoReplicate = req.autoReplicate;
    model.cronSchedule = req.cronSchedule;
    model.createdBy = req.createdBy;
    model.createdAt = clockSeconds();
    model.modifiedAt = model.createdAt;

    repo.save(model);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateModel(DistributionModelId id, UpdateDistributionModelRequest req) {
    auto model = repo.findById(id);
    if (model.id.isEmpty)
      return CommandResult(false, "", "Distribution model not found");

    if (req.name.length > 0)
      model.name = req.name;
    if (req.description.length > 0)
      model.description = req.description;
    if (req.status.length > 0)
      model.status = parseStatus(req.status);
    if (req.targetClientIds.length > 0)
      model.targetClientIds = req.targetClientIds;
    if (req.categories.length > 0)
      model.categories = parseCategories(req.categories);
    if (req.dataModelIds.length > 0)
      model.dataModelIds = req.dataModelIds;
    if (req.filterRuleIds.length > 0)
      model.filterRuleIds = req.filterRuleIds;
    model.autoReplicate = req.autoReplicate;
    if (req.cronSchedule.length > 0)
      model.cronSchedule = req.cronSchedule;
    model.modifiedAt = clockSeconds();

    repo.update(model);
    return CommandResult(true, id.toString, "");
  }

  CommandResult activate(DistributionModelId id) {
    auto model = repo.findById(id);
    if (model.id.isEmpty)
      return CommandResult(false, "", "Distribution model not found");
    model.status = DistributionModelStatus.active;
    model.modifiedAt = clockSeconds();
    repo.update(model);
    return CommandResult(true, id.toString, "");
  }

  CommandResult deactivate(DistributionModelId id) {
    auto model = repo.findById(id);
    if (model.id.isEmpty)
      return CommandResult(false, "", "Distribution model not found");
    model.status = DistributionModelStatus.inactive;
    model.modifiedAt = clockSeconds();
    repo.update(model);
    return CommandResult(true, id.toString, "");
  }

  DistributionModel getModel(DistributionModelId id) {
    return repo.findById(id);
  }

  DistributionModel[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DistributionModel[] listByStatus(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, parseStatus(status));
  }

  CommandResult deleteModel(DistributionModelId id) {
    auto model = repo.findById(id);
    if (model.id.isEmpty)
      return CommandResult(false, "", "Distribution model not found");
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private DistributionDirection parseDirection(string s) {
    switch (s) {
    case "outbound":
      return DistributionDirection.outbound;
    case "inbound":
      return DistributionDirection.inbound;
    case "bidirectional":
      return DistributionDirection.bidirectional;
    default:
      return DistributionDirection.outbound;
    }
  }

  private DistributionModelStatus parseStatus(string s) {
    switch (s) {
    case "active":
      return DistributionModelStatus.active;
    case "inactive":
      return DistributionModelStatus.inactive;
    case "draft":
      return DistributionModelStatus.draft;
    default:
      return DistributionModelStatus.draft;
    }
  }

  private MasterDataCategory[] parseCategories(string[] cats) {
    MasterDataCategory[] result;
    foreach (s; cats) {
      switch (s) {
      case "businessPartner":
        result ~= MasterDataCategory.businessPartner;
        break;
      case "costCenter":
        result ~= MasterDataCategory.costCenter;
        break;
      case "profitCenter":
        result ~= MasterDataCategory.profitCenter;
        break;
      case "companyCode":
        result ~= MasterDataCategory.companyCode;
        break;
      case "workforcePerson":
        result ~= MasterDataCategory.workforcePerson;
        break;
      case "bankAccount":
        result ~= MasterDataCategory.bankAccount;
        break;
      case "plant":
        result ~= MasterDataCategory.plant;
        break;
      case "custom":
        result ~= MasterDataCategory.custom;
        break;
      default:
        break;
      }
    }
    return result;
  }
}


