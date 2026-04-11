/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.datasets;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.dataset;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;

class MemoryDatasetRepository : DatasetRepository {
  private Dataset[string] store;

  void save(Dataset entity) {
    store[entity.id] = entity;
  }

  void update(Dataset entity) {
    store[entity.id] = entity;
  }

  void remove(DatasetId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  Dataset* findById(DatasetId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Dataset* findByName(TenantId tenantId, string name) {
    foreach (e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  Dataset[] findByTenant(TenantId tenantId) {
    Dataset[] result;
    foreach (e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status) {
    Dataset[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  Dataset[] findByDataType(TenantId tenantId, DataType dataType) {
    Dataset[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.dataType == dataType)
        result ~= e;
    return result;
  }
}
