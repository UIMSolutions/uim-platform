/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.personal_data_models;

// import uim.platform.data_privacy.domain.entities.personal_data_model;
// import uim.platform.data_privacy.domain.ports.repositories.personal_data_models;
// import uim.platform.data_privacy.application.dto;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManagePersonalDataModelsUseCase { 
  
  UsecaseResult createModel(CreatePersonalDataModelRequest req);
  PersonalDataModel getModel(TenantId tenantId, PersonalDataModelId id);
  PersonalDataModel[] listModels(TenantId tenantId);
  PersonalDataModel[] listModels(TenantId tenantId, PersonalDataCategory category);
  PersonalDataModel[] listSpecialCategories(TenantId tenantId);
  UsecaseResult updateModel(UpdatePersonalDataModelRequest req);
  UsecaseResult deleteModel(TenantId tenantId, PersonalDataModelId id);
  
}
