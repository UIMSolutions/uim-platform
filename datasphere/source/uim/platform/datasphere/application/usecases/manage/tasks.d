/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.tasks;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.task;
import uim.platform.datasphere.domain.ports.repositories.tasks;
import uim.platform.datasphere.domain.services.task_scheduler;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

alias Task = uim.platform.datasphere.domain.entities.task.Task;

class ManageTasksUseCase : UIMUseCase {
  private TaskRepository repo;

  this(TaskRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateTaskRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Task name is required");
    if (r.spaceid.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID().to!string;

    Task t;
    t.id = id;
    t.tenantId = r.tenantId;
    t.spaceId = r.spaceId;
    t.name = r.name;
    t.description = r.description;
    t.targetObjectId = r.targetObjectId;
    t.scheduleExpression = r.scheduleExpression;
    t.status = TaskStatus.scheduled;
    t.maxRetries = r.maxRetries;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    t.createdAt = now;
    t.modifiedAt = now;

    repo.save(t);
    return CommandResult(true, t.id, "");
  }

  Task get_(TaskId id, SpaceId spaceId) {
    return repo.findById(id, spaceId);
  }

  Task[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult patch(PatchTaskRequest r) {
    auto existing = repo.findById(r.taskId, r.spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Task not found");

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(TaskId id, SpaceId spaceId) {
    auto existing = repo.findById(id, spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Task not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id, "");
  }
}
