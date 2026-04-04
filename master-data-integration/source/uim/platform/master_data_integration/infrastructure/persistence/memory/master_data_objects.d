/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory
  .master_data_object_repo;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.master_data_object;
import uim.platform.master_data_integration.domain.ports.repositories.master_data_objects;

// import std.algorithm : filter;
// import std.array : array;

class MemoryMasterDataObjectRepository : MasterDataObjectRepository {
  private MasterDataObject[MasterDataObjectId] store;

  MasterDataObject findById(MasterDataObjectId id)
  {
    if (auto p = id in store)
      return *p;
    return MasterDataObject.init;
  }

  MasterDataObject[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  MasterDataObject[] findByCategory(TenantId tenantId, MasterDataCategory category)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.category == category).array;
  }

  MasterDataObject[] findByDataModel(TenantId tenantId, DataModelId dataModelId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.dataModelId == dataModelId)
      .array;
  }

  MasterDataObject[] findBySourceSystem(TenantId tenantId, string sourceSystem)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.sourceSystem == sourceSystem).array;
  }

  MasterDataObject findByGlobalId(TenantId tenantId, string globalId)
  {
    foreach (ref obj; store.byValue())
    {
      if (obj.tenantId == tenantId && obj.globalId == globalId)
        return obj;
    }
    return MasterDataObject.init;
  }

  void save(MasterDataObject obj)
  {
    store[obj.id] = obj;
  }

  void update(MasterDataObject obj)
  {
    store[obj.id] = obj;
  }

  void remove(MasterDataObjectId id)
  {
    store.remove(id);
  }
}
