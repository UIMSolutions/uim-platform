/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.tasks;

// import uim.platform.datasphere.domain.entities.task;
// import uim.platform.datasphere.domain.ports.repositories.tasks;
// import uim.platform.datasphere.domain.services.task_scheduler;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class ManageTasksUseCase {
  protected ITaskRepository tasks;

  this(ITaskRepository tasks) {
    this.tasks = tasks;
  }

  UsecaseResult createTask(CreateTaskRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "Task name is required");

    if (r.spaceId.isEmpty)
      return UsecaseResult(false, "", "Space ID is required");

    auto t = DSTask(r.tenantId);
    t.spaceId = r.spaceId;
    t.name = r.name;
    t.description = r.description;
    t.targetObjectId = r.targetObjectId;
    t.scheduleExpression = r.scheduleExpression;
    t.status = TaskStatus.scheduled;
    t.maxRetries = r.maxRetries;

    tasks.save(t);
    return UsecaseResult(true, t.id.value, "");
  }

  DSTask getTask(TenantId tenantId, SpaceId spaceId, TaskId id) {
    return tasks.findById(tenantId, spaceId, id);
  }

  DSTask[] listTasks(TenantId tenantId, SpaceId spaceId) {
    return tasks.findBySpace(tenantId, spaceId);
  }

  UsecaseResult patchTask(PatchTaskRequest r) {
    auto task = tasks.findById(r.tenantId, r.spaceId, r.taskId);
    if (task.isNull)
      return UsecaseResult(false, "", "Task not found");

    
    task.updatedAt = currentTimestamp;

    tasks.update(task);
    return UsecaseResult(true, task.id.value, "");
  }

  UsecaseResult deleteTask(TenantId tenantId, SpaceId spaceId, TaskId id) {
    auto task = tasks.findById(tenantId, spaceId, id);
    if (task.isNull)
      return UsecaseResult(false, "", "Task not found");

    tasks.remove(task);
    return UsecaseResult(true, task.id.value, "");
  }
}
