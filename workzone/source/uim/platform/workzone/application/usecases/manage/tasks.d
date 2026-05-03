/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.tasks;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.task;
// import uim.platform.workzone.domain.ports.repositories.tasks;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageTasksUseCase { // TODO: UIMUseCase {
  private TaskRepository repo;

  this(TaskRepository repo) {
    this.repo = repo;
  }

  CommandResult createTask(CreateTaskRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "WZTask title is required");

    auto now = Clock.currStdTime();
    auto t = WZTask();
    t.id = randomUUID();
    t.tenantId = req.tenantId;
    t.assigneeId = req.assigneeId;
    t.assigneeName = req.assigneeName;
    t.creatorId = req.creatorId;
    t.creatorName = req.creatorName;
    t.title = req.title;
    t.description = req.description;
    t.status = TaskStatus.open;
    t.priority = req.priority;
    t.sourceApp = req.sourceApp;
    t.sourceTaskId = req.sourceTaskId;
    t.actionUrl = req.actionUrl;
    t.category = req.category;
    t.tags = req.tags;
    t.dueDate = req.dueDate;
    t.createdAt = now;
    t.updatedAt = now;

    repo.save(t);
    return CommandResult(true, t.id.value, "");
  }

  WZTask getTask(TenantId tenantId, TaskId id) {
    return repo.findById(tenantId, id);
  }

  WZTask[] listByAssignee(TenantId tenantId, UserId assigneeId) {
    return repo.findByAssignee(tenantId, assigneeId);
  }

  WZTask[] listByStatus(TenantId tenantId, TaskStatus status, UserId assigneeId) {
    return repo.findByStatus(tenantId, status, assigneeId);
  }

  CommandResult updateTask(UpdateTaskRequest req) {
    auto t = repo.findById(req.tenantId, req.id);
    if (t.isNull)
      return CommandResult(false, "", "WZTask not found");

    if (req.title.length > 0)
      t.title = req.title;
    if (req.description.length > 0)
      t.description = req.description;
    t.status = req.status;
    t.priority = req.priority;
    if (req.dueDate > 0)
      t.dueDate = req.dueDate;
    t.updatedAt = Clock.currStdTime();

    if (t.status == TaskStatus.completed && t.completedAt == 0)
      t.completedAt = Clock.currStdTime();

    repo.update(t);
    return CommandResult(true, t.id.value, "");
  }

  CommandResult completeTask(TenantId tenantId, TaskId id) {
    auto t = repo.findById(tenantId, id);
    if (t.isNull)
      return CommandResult(false, "", "WZTask not found");

    t.status = TaskStatus.completed;
    t.completedAt = Clock.currStdTime();
    t.updatedAt = Clock.currStdTime();
    repo.update(t);
    return CommandResult(true, t.id.value, "");
  }

  CommandResult deleteTask(TenantId tenantId, TaskId id) {
    auto t = repo.findById(tenantId, id);
    if (t.isNull)
      return CommandResult(false, "", "WZTask not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
