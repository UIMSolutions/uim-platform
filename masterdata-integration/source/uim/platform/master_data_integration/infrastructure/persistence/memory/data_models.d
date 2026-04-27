/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.data_model;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.data_model;
import uim.platform.master_data_integration.domain.ports.repositories.data_models;

// import std.algorithm : filter;
// import std.array : array;

class MemoryDataModelRepository : TenantRepository!(DataModel, DataModelId), DataModelRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!((e) => e.name == name);
  }
  DataModel findByName(TenantId tenantId, string name) {
    foreach (m; findByTenant(tenantId)) {
      if (m.name == name)
        return m;
    }
    return DataModel.init;
  }

  size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }
  DataModel[] filterByCategory(DataModel[] models, MasterDataCategory category) {
    return models.filter!(e => e.category == category).array;
  }
  DataModel[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return filterByCategory(findByTenant(tenantId), category);
  }
  void removeByCategory(TenantId tenantId, MasterDataCategory category) {
    findByCategory(tenantId, category).each!(e => remove(e.id));
  }

}
