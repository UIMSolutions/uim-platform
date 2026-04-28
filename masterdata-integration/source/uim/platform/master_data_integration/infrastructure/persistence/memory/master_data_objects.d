/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory
  .master_data_object;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.master_data_object;
import uim.platform.master_data_integration.domain.ports.repositories.master_data_objects;

// import std.algorithm : filter;
// import std.array : array;

class MemoryMasterDataObjectRepository : MasterDataObjectRepository {

  size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }

  MasterDataObject[] filterByCategory(MasterDataObject[] objects, MasterDataCategory category) {
    return objects.filter!(e => e.category == category).array;
  }

  MasterDataObject[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByTenant(tenantId).filter!(e => e.category == category).array;
  }

  void removeByCategory(TenantId tenantId, MasterDataCategory category) {
    findByCategory(tenantId, category).each!(e => remove(e));
  }

  size_t countByDataModel(TenantId tenantId, DataModelId dataModelId) {
    return findByDataModel(tenantId, dataModelId).length;
  }

  MasterDataObject[] filterByDataModel(MasterDataObject[] objects, DataModelId dataModelId) {
    return objects.filter!(e => e.dataModelId == dataModelId).array;
  }

  MasterDataObject[] findByDataModel(TenantId tenantId, DataModelId dataModelId) {
    return findByTenant(tenantId).filter!(e => e.dataModelId == dataModelId).array;
  }

  void removeByDataModel(TenantId tenantId, DataModelId dataModelId) {
    findByDataModel(tenantId, dataModelId).each!(e => remove(e));
  }

  size_t countBySourceSystem(TenantId tenantId, string sourceSystem) {
    return findBySourceSystem(tenantId, sourceSystem).length;
  }

  MasterDataObject[] filterBySourceSystem(MasterDataObject[] objects, string sourceSystem) {
    return objects.filter!(e => e.sourceSystem == sourceSystem).array;
  }

  MasterDataObject[] findBySourceSystem(TenantId tenantId, string sourceSystem) {
    return findByTenant(tenantId).filter!(e => e.sourceSystem == sourceSystem).array;
  }

  void removeBySourceSystem(TenantId tenantId, string sourceSystem) {
    findBySourceSystem(tenantId, sourceSystem).each!(e => remove(e));
  }

  bool existsByGlobalId(TenantId tenantId, string globalId) {
    return findByGlobalId(tenantId, globalId).id != MasterDataObjectId.init;
  }

  MasterDataObject findByGlobalId(TenantId tenantId, string globalId) {
    foreach (obj; findByTenant(tenantId)) {
      if (obj.globalId == globalId)
        return obj;
    }
    return MasterDataObject.init;
  }

}
