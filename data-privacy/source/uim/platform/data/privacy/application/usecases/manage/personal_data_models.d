/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.personal_data_models;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.personal_data_model;
// import uim.platform.data.privacy.domain.ports.repositories.personal_data_models;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManagePersonalDataModelsUseCase { // TODO: UIMUseCase {
  private PersonalDataModelRepository repo;

  this(PersonalDataModelRepository repo) {
    this.repo = repo;
  }

  CommandResult createModel(CreatePersonalDataModelRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.fieldName.length == 0)
      return CommandResult(false, "", "Field name is required");
    if (req.sourceSystem.length == 0)
      return CommandResult(false, "", "Source system is required");

    auto now = Clock.currStdTime();
    auto model = PersonalDataModel();
    model.id = randomUUID();
    model.tenantId = req.tenantId;
    model.fieldName = req.fieldName;
    model.fieldDescription = req.fieldDescription;
    model.category = req.category;
    model.sensitivity = req.sensitivity;
    model.sourceSystem = req.sourceSystem;
    model.sourceEntity = req.sourceEntity;
    model.subjectType = req.subjectType;
    model.isSpecialCategory = req.isSpecialCategory;
    model.legalReference = req.legalReference;
    model.createdAt = now;
    model.updatedAt = now;

    repo.save(model);
    return CommandResult(model.id, "");
  }

  PersonalDataModel* getModel(PersonalDataModelId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  PersonalDataModel[] listModels(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  PersonalDataModel[] listByCategory(TenantId tenantId, PersonalDataCategory category) {
    return repo.findByCategory(tenantId, category);
  }

  PersonalDataModel[] listSpecialCategories(TenantId tenantId) {
    return repo.findSpecialCategories(tenantId);
  }

  CommandResult updateModel(UpdatePersonalDataModelRequest req) {
    auto model = repo.findById(req.id, req.tenantId);
    if (model.isNull)
      return CommandResult(false, "", "Personal data model not found");

    if (req.fieldName.length > 0)
      model.fieldName = req.fieldName;
    if (req.fieldDescription.length > 0)
      model.fieldDescription = req.fieldDescription;
    model.category = req.category;
    model.sensitivity = req.sensitivity;
    if (req.sourceSystem.length > 0)
      model.sourceSystem = req.sourceSystem;
    if (req.sourceEntity.length > 0)
      model.sourceEntity = req.sourceEntity;
    model.isSpecialCategory = req.isSpecialCategory;
    if (req.legalReference.length > 0)
      model.legalReference = req.legalReference;
    model.updatedAt = Clock.currStdTime();

    repo.update(model);
    return CommandResult(model.id, "");
  }

  void deleteModel(PersonalDataModelId tenantId, id tenantId) {
    repo.removeById(tenantId, id);
  }
}
