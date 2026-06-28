/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory
  .master_data_objects;

// import uim.platform.master_data_integration.domain.entities.master_data_object;
// import uim.platform.master_data_integration.domain.ports.repositories.master_data_objects;


 import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:

class MemoryMasterDataObjectRepository : TenantRepository!(MasterDataObject, MasterDataObjectId), MasterDataObjectRepository {

  size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }

  MasterDataObject[] filterByCategory(MasterDataObject[] objects, MasterDataCategory category) {
    return objects.filter!(e => e.category == category).array;
  }

  MasterDataObject[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return find(tenantId).filter!(e => e.category == category).array;
  }

  void removeByCategory(TenantId tenantId, MasterDataCategory category) {
    findByCategory(tenantId, category).each!(e => remove(e));
  }

  size_t countByDataModel(TenantId tenantId, DataModelId modelId) {
    return findByDataModel(tenantId, modelId).length;
  }

  MasterDataObject[] filterByDataModel(MasterDataObject[] objects, DataModelId modelId) {
    return objects.filter!(e => e.modelId == modelId).array;
  }

  MasterDataObject[] findByDataModel(TenantId tenantId, DataModelId modelId) {
    return find(tenantId).filter!(e => e.modelId == modelId).array;
  }

  void removeByDataModel(TenantId tenantId, DataModelId modelId) {
    findByDataModel(tenantId, modelId).each!(e => remove(e));
  }

  size_t countBySourceSystem(TenantId tenantId, string sourceSystem) {
    return findBySourceSystem(tenantId, sourceSystem).length;
  }

  MasterDataObject[] filterBySourceSystem(MasterDataObject[] objects, string sourceSystem) {
    return objects.filter!(e => e.sourceSystem == sourceSystem).array;
  }

  MasterDataObject[] findBySourceSystem(TenantId tenantId, string sourceSystem) {
    return find(tenantId).filter!(e => e.sourceSystem == sourceSystem).array;
  }

  void removeBySourceSystem(TenantId tenantId, string sourceSystem) {
    findBySourceSystem(tenantId, sourceSystem).each!(e => remove(e));
  }

  bool existsByGlobal(TenantId tenantId, string globalId) {
    return findByGlobal(tenantId, globalId).id != MasterDataObjectId.init;
  }

  MasterDataObject findByGlobal(TenantId tenantId, string globalId) {
    foreach (obj; find(tenantId)) {
      if (obj.globalId == globalId)
        return obj;
    }
    return MasterDataObject.init;
  }

  void removeByGlobal(TenantId tenantId, string globalId) {
    remove(findByGlobal(tenantId, globalId));
  }
}
