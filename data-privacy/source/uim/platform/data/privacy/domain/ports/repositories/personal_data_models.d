/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.personal_data_models;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.personal_data_model;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting personal data model definitions.
interface PersonalDataModelRepository : ITenantRepository!(PersonalDataModel, PersonalDataModelId) {

  size_t countByCategory(TenantId tenantId, PersonalDataCategory category);
  PersonalDataModel[] findByCategory(TenantId tenantId, PersonalDataCategory category);
  void removeByCategory(TenantId tenantId, PersonalDataCategory category);

  size_t countBySourceSystem(TenantId tenantId, string sourceSystem);
  PersonalDataModel[] findBySourceSystem(TenantId tenantId, string sourceSystem);
  void removeBySourceSystem(TenantId tenantId, string sourceSystem);

  size_t countBySubjectType(TenantId tenantId, DataSubjectType subjectType);
  PersonalDataModel[] findBySubjectType(TenantId tenantId, DataSubjectType subjectType);
  void removeBySubjectType(TenantId tenantId, DataSubjectType subjectType);

  size_t countSpecialCategories(TenantId tenantId);
  PersonalDataModel[] findSpecialCategories(TenantId tenantId);
  void removeSpecialCategories(TenantId tenantId);

}
