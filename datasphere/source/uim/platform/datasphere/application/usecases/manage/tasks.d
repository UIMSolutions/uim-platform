/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.tasks;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.task;
// import uim.platform.datasphere.domain.ports.repositories.tasks;
// import uim.platform.datasphere.domain.services.task_scheduler;
// import uim.platform.datasphere.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class ManageTasksUseCase { // TODO: UIMUseCase {
  private TaskRepository tasks;

  this(TaskRepository tasks) {
    this.tasks = tasks;
  }

  CommandResult create(CreateTaskRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Task name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    DSTask t;
    t.initEntity(r.tenantId);
    t.spaceId = r.spaceId;
    t.name = r.name;
    t.description = r.description;
    t.targetObjectId = r.targetObjectId;
    t.scheduleExpression = r.scheduleExpression;
    t.status = TaskStatus.scheduled;
    t.maxRetries = r.maxRetries;

    tasks.save(t);
    return CommandResult(true, t.id.value, "");
  }

  DSTask getById(TaskId id, SpaceId spaceId) {
    return tasks.findById(id, spaceId);
  }

  DSTask[] list(SpaceId spaceId) {
    return tasks.findBySpace(spaceId);
  }

  CommandResult patch(PatchTaskRequest r) {
    auto existing = tasks.findById(r.taskId, r.spaceId);
    if (existing.isNull)
      return CommandResult(false, "", "Task not found");

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    tasks.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult remove(TaskId id, SpaceId spaceId) {
    auto existing = tasks.findById(id, spaceId);
    if (existing.isNull)
      return CommandResult(false, "", "Task not found");

    tasks.remove(id, spaceId);
    return CommandResult(true, id.value, "");
  }
}
