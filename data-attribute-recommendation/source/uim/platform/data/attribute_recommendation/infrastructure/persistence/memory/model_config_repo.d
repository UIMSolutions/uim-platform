/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.model_configs;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_configuration;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.model_configs;

class MemoryModelConfigRepository : ModelConfigRepository {
  private ModelConfiguration[string] store;

  void save(ModelConfiguration entity) {
    store[entity.id] = entity;
  }

  void update(ModelConfiguration entity) {
    store[entity.id] = entity;
  }

  void remove(ModelConfigId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  ModelConfiguration* findById(ModelConfigId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ModelConfiguration* findByName(TenantId tenantId, string name) {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  ModelConfiguration[] findByTenant(TenantId tenantId) {
    ModelConfiguration[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ModelConfiguration[] findByDataset(DatasetId datasettenantId, id tenantId) {
    ModelConfiguration[] result;
    foreach (ref e; store)
      if (e.datasetId == datasetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ModelConfiguration[] findByStatus(TenantId tenantId, ModelConfigStatus status) {
    ModelConfiguration[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
