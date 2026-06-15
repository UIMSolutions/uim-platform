/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.data_model;

// import uim.platform.master_data_integration.domain.entities.data_model;
// import uim.platform.master_data_integration.domain.ports.repositories.data_models;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:
/// Application service for data model / schema management.
class ManageDataModelsUseCase { // TODO: UIMUseCase {
  private DataModelRepository repo;

  this(DataModelRepository repo) {
    this.repo = repo;
  }

  CommandResult createModel(CreateDataModelRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Data model name is required");
    if (req.namespace.length == 0)
      return CommandResult(false, "", "Namespace is required");

    DataModel model;
    model.initEntity(req.tenantId, req.createdBy);

    model.name = req.name;
    model.namespace = req.namespace;
    model.version_ = req.version_.length > 0 ? req.version_ : "1.0.0";
    model.description = req.description;
    model.category = req.category.to!MasterDataCategory;
    model.fields = toFieldDefs(req.fields);
    model.keyFields = req.keyFields;
    model.requiredFields = req.requiredFields;
    model.isActive = true;

    repo.save(model);
    return CommandResult(true, model.id.value, "");
  }

  CommandResult updateModel(UpdateDataModelRequest req) {
    auto model = repo.findById(req.tenantId, req.modelId);
    if (model.isNull)
      return CommandResult(false, "", "Data model not found");

    if (req.description.length > 0)
      model.description = req.description;
    if (req.version_.length > 0)
      model.version_ = req.version_;
    if (req.fields.length > 0)
      model.fields = toFieldDefs(req.fields);
    if (req.keyFields.length > 0)
      model.keyFields = req.keyFields;
    if (req.requiredFields.length > 0)
      model.requiredFields = req.requiredFields;
    model.updatedAt = currentTimestamp();

    repo.update(model);
    return CommandResult(true, model.id.value, "");
  }

  DataModel getModel(TenantId tenantId, DataModelId id) {
    return repo.findById(tenantId, id);
  }

  DataModel[] listModelsByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DataModel[] listModelsByCategory(TenantId tenantId, string category) {
    return repo.findByCategory(tenantId, toMasterDataCategory(category));
  }

  DataModel findModelByName(TenantId tenantId, string name) {
    return repo.findByName(tenantId, name);
  }

  CommandResult deleteModel(TenantId tenantId, DataModelId id) {
    auto model = repo.findById(tenantId, id);
    if (model.isNull)
      return CommandResult(false, "", "Data model not found");

    repo.remove(model);
    return CommandResult(true, model.id.value, "");
  }

  private FieldDefinition[] toFieldDefs(FieldDefinitionDto[] dtos) {
    FieldDefinition[] result;
    foreach (dto; dtos) {
      FieldDefinition fd;
      fd.name = dto.name;
      fd.displayName = dto.displayName;
      fd.type_ = dto.type_.to!FieldType;
      fd.isRequired = dto.isRequired;
      fd.isKey = dto.isKey;
      fd.defaultValue = dto.defaultValue;
      fd.maxLength = dto.maxLength;
      fd.referenceModel = dto.referenceModel;
      fd.description = dto.description;
      result ~= fd;
    }
    return result;
  }
}


