/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.tasks;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.task;
import uim.platform.workzone.domain.ports.repositories.tasks;
import uim.platform.workzone.application.dto;

class ManageTasksUseCase { // TODO: UIMUseCase {
  private TaskRepository repo;

  this(TaskRepository repo) {
    this.repo = repo;
  }

  CommandResult createTask(CreateTaskRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Task title is required");

    auto now = Clock.currStdTime();
    auto t = Task();
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
    return CommandResult(t.id, "");
  }

  Task* getTask(TaskId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Task[] listByAssignee(UserId assigneetenantId, id tenantId) {
    return repo.findByAssignee(assigneetenantId, id);
  }

  Task[] listByStatus(TaskStatus status, UserId assigneetenantId, id tenantId) {
    return repo.findByStatus(status, assigneetenantId, id);
  }

  CommandResult updateTask(UpdateTaskRequest req) {
    auto t = repo.findById(req.id, req.tenantId);
    if (t.isNull)
      return CommandResult(false, "", "Task not found");

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

    repo.update(*t);
    return CommandResult(t.id, "");
  }

  CommandResult completeTask(TaskId tenantId, id tenantId) {
    auto t = repo.findById(tenantId, id);
    if (t.isNull)
      return CommandResult(false, "", "Task not found");

    t.status = TaskStatus.completed;
    t.completedAt = Clock.currStdTime();
    t.updatedAt = Clock.currStdTime();
    repo.update(*t);
    return CommandResult(t.id, "");
  }

  void deleteTask(TaskId tenantId, id tenantId) {
    repo.removeById(tenantId, id);
  }
}
