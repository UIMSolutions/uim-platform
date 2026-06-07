/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.data_flow;

// import uim.platform.datasphere.domain.entities.data_flow;
// import uim.platform.datasphere.domain.ports.repositories.data_flows;


 
import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class MemoryDataFlowRepository : TenantRepository!(DataFlow, DataFlowId), DataFlowRepository {
  
  // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    return findBySpace(tenantId, spaceId).any!(ca => ca.id == id);
  }

  CatalogAsset findById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    foreach (ca; findBySpace(tenantId, spaceId)) {
      if (ca.id == id)
        return ca;
    }
    return CatalogAsset.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    remove(findById(tenantId, spaceId, id));
  }
  // #endregion ById

  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  DataFlow[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(df => remove(df));
  }
  // #endregion BySpace

  DataFlow[] findByStatus(SpaceId spaceId, FlowStatus status) {
    if (spaceId in store)
      return store[spaceId].filter!(df => df.status == status).array;
    return null;
  }
}
