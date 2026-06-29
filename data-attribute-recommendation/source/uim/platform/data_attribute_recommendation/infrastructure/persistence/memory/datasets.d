/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.datasets;


import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
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
    remove(findByName(tenantId, name));
  }

  size_t countByStatus(TenantId tenantId, DatasetStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Dataset[] filterByStatus(Dataset[] datasets, DatasetStatus status) {
    return datasets.filter!(e => e.status == status).array;
  }

  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DatasetStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByDataType(TenantId tenantId, DataType dataType) {
    return findByDataType(tenantId, dataType).length;
  }

  Dataset[] filterByDataType(Dataset[] datasets, DataType dataType) {
    return datasets.filter!(e => e.dataType == dataType).array;
  }

  Dataset[] findByDataType(TenantId tenantId, DataType dataType) {
    return filterByDataType(findByTenant(tenantId), dataType);
  }

  void removeByDataType(TenantId tenantId, DataType dataType) {
    findByDataType(tenantId, dataType).each!(e => remove(e));
  }
}
