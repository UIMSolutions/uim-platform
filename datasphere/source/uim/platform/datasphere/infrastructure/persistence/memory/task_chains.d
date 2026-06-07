/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.task_chain;

// import uim.platform.datasphere.domain.entities.task_chain;
// import uim.platform.datasphere.domain.ports.repositories.task_chains;


 
import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class MemoryTaskChainRepository : TenantRepository!(TaskChain, TaskChainId), TaskChainRepository {
  
  // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, TaskChainId id) {
    return findBySpace(tenantId, spaceId).any!(tc => tc.id == id);
  }

  TaskChain findById(TenantId tenantId, SpaceId spaceId, TaskChainId id) {
    foreach (tc; findBySpace(tenantId, spaceId)) {
      if (tc.id == id)
        return tc;
    }
    return TaskChain.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, TaskChainId id) {
    remove(findById(tenantId, spaceId, id));
  }
  // #endregion ById

  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  TaskChain[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(tc => remove(tc));
  }
  // #endregion BySpace

  TaskChain[] findByStatus(SpaceId spaceId, TaskStatus status) {
    if (spaceId in store)
      return store[spaceId].filter!(tc => tc.status == status).array;
    return null;
  }
}
