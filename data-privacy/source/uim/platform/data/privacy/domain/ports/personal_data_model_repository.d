module uim.platform.data.privacy.domain.ports.personal_data_model_repository;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.personal_data_model;

/// Port for persisting personal data model definitions.
interface PersonalDataModelRepository
{
  PersonalDataModel[] findByTenant(TenantId tenantId);
  PersonalDataModel* findById(PersonalDataModelId id, TenantId tenantId);
  PersonalDataModel[] findByCategory(TenantId tenantId, PersonalDataCategory category);
  PersonalDataModel[] findBySourceSystem(TenantId tenantId, string sourceSystem);
  PersonalDataModel[] findBySubjectType(TenantId tenantId, DataSubjectType subjectType);
  PersonalDataModel[] findSpecialCategories(TenantId tenantId);
  void save(PersonalDataModel model);
  void update(PersonalDataModel model);
  void remove(PersonalDataModelId id, TenantId tenantId);
}
