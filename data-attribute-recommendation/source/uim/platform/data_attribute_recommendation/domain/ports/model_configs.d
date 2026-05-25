/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.ports.repositories.model_configs;

// import uim.platform.data_attribute_recommendation.domain.types;
// import uim.platform.data_attribute_recommendation.domain.entities.model_configuration;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
interface ModelConfigRepository : ITenantRepository!(ModelConfiguration, ModelConfigId) {

  bool existsByName(TenantId tenantId, string name);
  ModelConfiguration findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByDataset(TenantId tenantId, DatasetId datasetId);
  ModelConfiguration[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void removeByDataset(TenantId tenantId, DatasetId datasetId);

  size_t countByStatus(TenantId tenantId, ModelConfigStatus status);
  ModelConfiguration[] findByStatus(TenantId tenantId, ModelConfigStatus status);
  void removeByStatus(TenantId tenantId, ModelConfigStatus status);

}
