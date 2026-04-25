/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.model_configs;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_configuration;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.model_configs;

class MemoryModelConfigRepository : TenantRepository!(ModelConfiguration, ModelConfigId), ModelConfigRepository {
  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }
  ModelConfiguration findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return ModelConfiguration.init;
  }

  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }
  ModelConfiguration[] filterByDataset(ModelConfiguration[] configs, DatasetId datasetId) {
    return configs.filter!(e => e.datasetId == datasetId).array;
  }
  ModelConfiguration[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByTenant(tenantId).filterByDataset(datasetId);
  }
  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).removeAll;
  }

  size_t countByStatus(TenantId tenantId, ModelConfigStatus status) {
    return findByStatus(tenantId, status).length;
  }
  ModelConfiguration[] filterByStatus(ModelConfiguration[] configs, ModelConfigStatus status) {
    return configs.filter!(e => e.status == status).array;
  }
  ModelConfiguration[] findByStatus(TenantId tenantId, ModelConfigStatus status) {
    return findByTenant(tenantId).filterByStatus(status);
  }
  void removeByStatus(TenantId tenantId, ModelConfigStatus status) {
    findByStatus(tenantId, status).removeAll;
  }
}
