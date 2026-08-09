/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.personal_data_models;

// import uim.platform.data.privacy.domain.entities.personal_data_model;
// import uim.platform.data.privacy.domain.ports.repositories.personal_data_models;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManagePersonalDataModelsUseCase { 
  
  CommandResult createModel(CreatePersonalDataModelRequest req);
  PersonalDataModel getModel(TenantId tenantId, PersonalDataModelId id);
  PersonalDataModel[] listModels(TenantId tenantId);
  PersonalDataModel[] listModels(TenantId tenantId, PersonalDataCategory category);
  PersonalDataModel[] listSpecialCategories(TenantId tenantId);
  CommandResult updateModel(UpdatePersonalDataModelRequest req);
  CommandResult deleteModel(TenantId tenantId, PersonalDataModelId id);
  
}
