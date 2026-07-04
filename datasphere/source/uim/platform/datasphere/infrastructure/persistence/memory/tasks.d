/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.task;

// import uim.platform.datasphere.domain.entities.task;
// import uim.platform.datasphere.domain.ports.repositories.tasks;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryTaskRepository : TenantRepository!(Task, TaskId), TaskRepository {
  
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
  DSTask[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(t => remove(t));
  }
  // #endregion BySpace

  DSTask[] findByStatus(SpaceId spaceId, TaskStatus status) {
    if (spaceId in store)
      return store[spaceId].filter!(t => t.status == status).array;
    return null;
  }

  DSTask[] findByType(SpaceId spaceId, TaskType type) {
    if (spaceId in store)
      return store[spaceId].filter!(t => t.type == type).array;
    return null;
  }

  void save(DSTask t) {
    store[t.spaceId] ~= t;
  }

  void update(DSTask t) {
    if (t.spaceId in store) {
      foreach (existing; store[t.spaceId]) {
        if (existing.id == t.id) {
          existing = t;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, TaskId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(t => t.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
