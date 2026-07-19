/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.personal_data_models;


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
    if (req.fieldname.isEmpty)
      return CommandResult(false, "", "Field name is required");
    if (req.sourceSystem.length == 0)
      return CommandResult(false, "", "Source system is required");

    auto model = PersonalDataModel(req.tenantId);
    model.fieldName = req.fieldName;
    model.fieldDescription = req.fieldDescription;
    model.category = req.category.toPersonalDataCategory;
    model.sensitivity = req.sensitivity.toDataSensitivity;
    model.sourceSystem = req.sourceSystem;
    model.sourceEntity = req.sourceEntity;
    model.subjectType = req.subjectType.toDataSubjectType;
    model.isSpecialCategory = req.isSpecialCategory;
    model.legalReference = req.legalReference;

    repo.save(model);
    return CommandResult(true, model.id.value, "");
  }

  PersonalDataModel getModel(TenantId tenantId, PersonalDataModelId id) {
    return repo.findById(tenantId, id);
  }

  PersonalDataModel[] listModels(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  PersonalDataModel[] listModels(TenantId tenantId, PersonalDataCategory category) {
    return repo.findByCategory(tenantId, category);
  }

  PersonalDataModel[] listSpecialCategories(TenantId tenantId) {
    return repo.findSpecialCategories(tenantId);
  }

  CommandResult updateModel(UpdatePersonalDataModelRequest req) {
    auto model = repo.findById(req.tenantId, req.id);
    if (model.isNull)
      return CommandResult(false, "", "Personal data model not found");

    if (req.fieldName.length > 0)
      model.fieldName = req.fieldName;
    if (req.fieldDescription.length > 0)
      model.fieldDescription = req.fieldDescription;
    if (req.category.length > 0)
      model.category = req.category.toPersonalDataCategory;
    if (req.sensitivity.length > 0)
      model.sensitivity = req.sensitivity.toDataSensitivity;
    if (req.sourceSystem.length > 0)
      model.sourceSystem = req.sourceSystem;
    if (req.sourceEntity.length > 0)
      model.sourceEntity = req.sourceEntity;
    model.isSpecialCategory = req.isSpecialCategory;
    if (req.legalReference.length > 0)
      model.legalReference = req.legalReference;
    model.updatedAt = currentTimestamp();

    repo.update(model);
    return CommandResult(true, model.id.value, "");
  }

  CommandResult deleteModel(TenantId tenantId, PersonalDataModelId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Personal data model not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }
}
