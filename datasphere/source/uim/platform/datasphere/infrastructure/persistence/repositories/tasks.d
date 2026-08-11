/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.repositories.tasks;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class TaskRepository : TenantRepository!(DSTask, TaskId), ITaskRepository {
  
  // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, TaskId id) {
    return findBySpace(tenantId, spaceId).any!(ca => ca.id == id);
  }

  DSTask findById(TenantId tenantId, SpaceId spaceId, TaskId id) {
    foreach (t; findBySpace(tenantId, spaceId)) {
      if (t.id == id)
        return t;
    }
    return DSTask.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, TaskId id) {
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

  size_t countByStatus(TenantId tenantId,  SpaceId spaceId, TaskStatus status) {
    return findByStatus(tenantId, spaceId, status).length;
  }

  DSTask[] filterByStatus(DSTask[] tasks, TaskStatus status) {
    return tasks.filter!(t => t.status == status).array;
  }

  DSTask[] findByStatus(TenantId tenantId, SpaceId spaceId, TaskStatus status) {
    return filterByStatus(findBySpace(tenantId, spaceId), status);
  }

  void removeByStatus(TenantId tenantId, SpaceId spaceId, TaskStatus status) {
    findByStatus(tenantId, spaceId, status).each!(t => remove(t));
  }

  size_t countByType(TenantId tenantId, SpaceId spaceId, TaskType type) {
    return findByType(tenantId, spaceId, type).length;
  }

  DSTask[] filterByType(DSTask[] tasks, TaskType type) {
    return tasks.filter!(t => t.type == type).array;
  }

  DSTask[] findByType(TenantId tenantId, SpaceId spaceId, TaskType type) {
    return filterByType(findBySpace(tenantId, spaceId), type);
  }

  void removeByType(TenantId tenantId, SpaceId spaceId, TaskType type) {
    findByType(tenantId, spaceId, type).each!(t => remove(t));
  }

}
