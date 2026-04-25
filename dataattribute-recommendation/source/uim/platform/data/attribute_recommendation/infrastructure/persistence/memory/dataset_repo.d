/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.datasets;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.dataset;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;

class MemoryDatasetRepository : TenantRepository!(Dataset, DatasetId), DatasetRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }

  Dataset findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return Dataset.init;
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).remove;
  }

  size_t countByStatus(TenantId tenantId, DatasetStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Dataset[] filterByStatus(Dataset[] datasets, DatasetStatus status) {
    return datasets.filter!(e => e.status == status).array;
  }

  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status);
  }

  void removeByStatus(TenantId tenantId, DatasetStatus status) {
    findByStatus(tenantId, status).removeAll;
  }

  size_t countByDataType(TenantId tenantId, DataType dataType) {
    return findByDataType(tenantId, dataType).length;
  }

  Dataset[] filterByDataType(Dataset[] datasets, DataType dataType) {
    return datasets.filter!(e => e.dataType == dataType).array;
  }

  Dataset[] findByDataType(TenantId tenantId, DataType dataType) {
    return findByTenant(tenantId).filterByDataType(dataType);
  }

  void removeByDataType(TenantId tenantId, DataType dataType) {
    findByDataType(tenantId, dataType).removeAll;
  }
}
