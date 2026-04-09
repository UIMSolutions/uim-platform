/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.tasks;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.task;

interface TaskRepository {
  Task[] findByAssignee(UserId assigneetenantId, id tenantId);
  Task* findById(TaskId tenantId, id tenantId);
  Task[] findByStatus(TaskStatus status, UserId assigneetenantId, id tenantId);
  Task[] findByTenant(TenantId tenantId);
  void save(Task task);
  void update(Task task);
  void remove(TaskId tenantId, id tenantId);
}
