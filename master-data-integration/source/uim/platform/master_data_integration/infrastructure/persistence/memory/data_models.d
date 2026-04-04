/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.data_model_repo;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.data_model;
import uim.platform.master_data_integration.domain.ports.repositories.data_models;

// import std.algorithm : filter;
// import std.array : array;

class MemoryDataModelRepository : DataModelRepository {
  private DataModel[DataModelId] store;

  DataModel findById(DataModelId id)
  {
    if (auto p = id in store)
      return *p;
    return DataModel.init;
  }

  DataModel[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  DataModel[] findByCategory(TenantId tenantId, MasterDataCategory category)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.category == category).array;
  }

  DataModel findByName(TenantId tenantId, string name)
  {
    foreach (ref m; store.byValue())
    {
      if (m.tenantId == tenantId && m.name == name)
        return m;
    }
    return DataModel.init;
  }

  void save(DataModel model)
  {
    store[model.id] = model;
  }

  void update(DataModel model)
  {
    store[model.id] = model;
  }

  void remove(DataModelId id)
  {
    store.remove(id);
  }
}
