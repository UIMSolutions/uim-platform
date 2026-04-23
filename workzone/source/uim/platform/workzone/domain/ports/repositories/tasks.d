/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.tasks;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.task;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface TaskRepository : ITenantRepository!(Task, TaskId) {

  size_t countByAssignee(TenantId tenantId, UserId assignee);
  Task[] findByAssignee(TenantId tenantId, UserId assignee);
  void removeByAssignee(TenantId tenantId, UserId assignee);

  size_t countByStatus(TenantId tenantId, TaskStatus status, UserId assignee);
  Task[] findByStatus(TenantId tenantId, TaskStatus status, UserId assignee);
  void removeByStatus(TenantId tenantId, TaskStatus status, UserId assignee);

}
