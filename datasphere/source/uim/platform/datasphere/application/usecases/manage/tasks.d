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

// mixin(ShowModule!()); 

@safe:

class ManageTasksUseCase { // TODO: UIMUseCase {
  private TaskRepository tasks;

  this(TaskRepository tasks) {
    this.tasks = tasks;
  }

  CommandResult createTask(CreateTaskRequest r) {
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

  DSTask getTask(SpaceId spaceId, TaskId id) {
    return tasks.findById(spaceId, id);
  }

  DSTask[] listTasks(SpaceId spaceId) {
    return tasks.findBySpace(spaceId);
  }

  CommandResult patchTask(PatchTaskRequest r) {
    auto task = tasks.findById(r.spaceId, r.taskId);
    if (task.isNull)
      return CommandResult(false, "", "Task not found");

    import core.time : MonoTime;
    task.updatedAt = currentTimestamp;

    tasks.update(task);
    return CommandResult(true, task.id.value, "");
  }

  CommandResult deleteTask(SpaceId spaceId, TaskId id) {
    auto task = tasks.findById(spaceId, id);
    if (task.isNull)
      return CommandResult(false, "", "Task not found");

    tasks.remove(task);
    return CommandResult(true, task.id.value, "");
  }
}
