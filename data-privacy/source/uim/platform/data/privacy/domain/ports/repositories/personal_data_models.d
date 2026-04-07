/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.personal_data_models;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.personal_data_model;

/// Port for persisting personal data model definitions.
interface PersonalDataModelRepository {
  bool existsByTenant(TenantId tenantId);
  PersonalDataModel[] findByTenant(TenantId tenantId);
 
  bool existsId(PersonalDataModelId id, TenantId tenantId);
  PersonalDataModel findById(PersonalDataModelId id, TenantId tenantId);

  PersonalDataModel[] findByCategory(TenantId tenantId, PersonalDataCategory category);
  PersonalDataModel[] findBySourceSystem(TenantId tenantId, string sourceSystem);
  PersonalDataModel[] findBySubjectType(TenantId tenantId, DataSubjectType subjectType);
  PersonalDataModel[] findSpecialCategories(TenantId tenantId);

  void save(PersonalDataModel model);
  void update(PersonalDataModel model);
  void remove(PersonalDataModelId id, TenantId tenantId);
}
