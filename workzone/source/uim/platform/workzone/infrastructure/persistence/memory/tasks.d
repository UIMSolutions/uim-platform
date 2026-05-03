/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.tasks;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.task;
// import uim.platform.workzone.domain.ports.repositories.tasks;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryTaskRepository : TenantRepository!(WZTask, TaskId), TaskRepository {

  // #region ByAssignee
  size_t countByAssignee(TenantId tenantId, UserId assigneeId) {
    return findByAssignee(tenantId, assigneeId).length;
  }

  WZTask[] findByAssignee(TenantId tenantId, UserId assigneeId) {
    return findByTenant(tenantId).filter!(t => t.assigneeId == assigneeId).array;
  }

  void removeByAssignee(TenantId tenantId, UserId assigneeId) {
    return findByAssignee(tenantId, assigneeId).each!(t => remove(t));
  }
  // #endregion ByAssignee

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, TaskStatus status, UserId assigneeId) {
    return findByStatus(tenantId, status, assigneeId).length;
  }

  WZTask[] findByStatus(TenantId tenantId, TaskStatus status, UserId assigneeId) {
    return findByTenant(tenantId).filter!(t => t.assigneeId == assigneeId && t.status == status).array;
  }

  void removeByStatus(TenantId tenantId, TaskStatus status, UserId assigneeId) {
    return findByStatus(tenantId, status, assigneeId).each!(t => remove(t));
  }
  // #endregion ByStatus

}
