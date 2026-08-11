/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.repositories.data_flows;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class DataFlowRepository : TenantRepository!(DataFlow, DataFlowId), IDataFlowRepository {
  
  // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, DataFlowId id) {
    return findBySpace(tenantId, spaceId).any!(df => df.id == id);
  }

  DataFlow findById(TenantId tenantId, SpaceId spaceId, DataFlowId id) {
    foreach (df; findBySpace(tenantId, spaceId)) {
      if (df.id == id)
        return df;
    }
    return DataFlow.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, DataFlowId id) {
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

  size_t countByStatus(TenantId tenantId, SpaceId spaceId, FlowStatus status) {
    return findByStatus(tenantId, spaceId, status).length;
  }

  DataFlow[] filterByStatus(DataFlow[] flows, FlowStatus status) {
    return flows.filter!(df => df.status == status).array;
  }

  DataFlow[] findByStatus(TenantId tenantId, SpaceId spaceId, FlowStatus status) {
    return filterByStatus(findBySpace(tenantId, spaceId), status);
  }

  void removeByStatus(TenantId tenantId, SpaceId spaceId, FlowStatus status) {
    findByStatus(tenantId, spaceId, status).each!(df => remove(df));
  }
}
