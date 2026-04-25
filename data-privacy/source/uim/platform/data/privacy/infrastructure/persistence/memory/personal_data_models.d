/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.personal_data_models;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.personal_data_model;
// import uim.platform.data.privacy.domain.ports.repositories.personal_data_models;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryPersonalDataModelRepository : TenantRepository!(PersonalDataModel, PersonalDataModelId), PersonalDataModelRepository {

  size_t countByCategory(TenantId tenantId, PersonalDataCategory category) {
    return findByCategory(tenantId, category).length;
  }

  PersonalDataModel[] filterByCategory(PersonalDataModel[] models, PersonalDataCategory category) {
    return models.filter!(m => m.category == category).array;
  }

  PersonalDataModel[] findByCategory(TenantId tenantId, PersonalDataCategory category) {
    return filterByCategory(findByTenant(tenantId), category);
  }

  void removeByCategory(TenantId tenantId, PersonalDataCategory category) {
    findByCategory(tenantId, category).each!(entity => remove(entity.id));
  }

  size_t countBySourceSystem(TenantId tenantId, string sourceSystem) {
    return findBySourceSystem(tenantId, sourceSystem).length;
  }

  PersonalDataModel[] filterBySourceSystem(PersonalDataModel[] models, string sourceSystem) {
    return models.filter!(m => m.sourceSystem == sourceSystem).array;
  }

  PersonalDataModel[] findBySourceSystem(TenantId tenantId, string sourceSystem) {
    return filterBySourceSystem(findByTenant(tenantId), sourceSystem);
  }

  void removeBySourceSystem(TenantId tenantId, string sourceSystem) {
    findBySourceSystem(tenantId, sourceSystem).each!(entity => remove(entity.id));
  }

  size_t countBySubjectType(TenantId tenantId, DataSubjectType subjectType) {
    return findBySubjectType(tenantId, subjectType).length;
  }

  PersonalDataModel[] filterBySubjectType(PersonalDataModel[] models, DataSubjectType subjectType) {
    return models.filter!(m => m.subjectType == subjectType).array;
  }

  PersonalDataModel[] findBySubjectType(TenantId tenantId, DataSubjectType subjectType) {
    return filterBySubjectType(findByTenant(tenantId), subjectType);
  }

  void removeBySubjectType(TenantId tenantId, DataSubjectType subjectType) {
    findBySubjectType(tenantId, subjectType).each!(entity => remove(entity.id));
  }

  PersonalDataModel[] filterSpecialCategories(PersonalDataModel[] models) {
    return models.filter!(m => m.isSpecialCategory).array;
  }

  PersonalDataModel[] findSpecialCategories(TenantId tenantId) {
    return filterSpecialCategories(findByTenant(tenantId));
  }

  void removeSpecialCategories(TenantId tenantId) {
    findSpecialCategories(tenantId).each!(entity => remove(entity.id));
  }

}
