/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTasksUseCase { // TODO: UIMUseCase {
    private TaskRepository repo;

    this(TaskRepository repo) {
        this.repo = repo;
    }

    Task getById(string tenantId, string id) {
        return repo.findById(tenantId, id);
    }

    Task[] list(string tenantId) {
        return repo.findByTenant(tenantId);
    }

    Task[] listByAssignee(string tenantId, string assignee) {
        return repo.findByAssignee(tenantId, assignee);
    }

    Task[] listByStatus(string tenantId, TaskStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    Task[] listByProvider(string tenantId, string providerId) {
        return repo.findByProvider(tenantId, providerId);
    }

    Task[] listByCategory(string tenantId, TaskCategory category) {
        return repo.findByCategory(tenantId, category);
    }

    Task[] listByPriority(string tenantId, TaskPriority priority) {
        return repo.findByPriority(tenantId, priority);
    }

    CommandResult create(CreateTaskRequest req) {
        if (!TaskValidator.validate(req.id, req.title))
            return CommandResult(false, "", "Invalid task data");
        Task t;
        t.id = req.id;
        t.tenantId = req.tenantId;
        t.taskDefinitionId = req.taskDefinitionId;
        t.providerId = req.providerId;
        t.externalTaskId = req.externalTaskId;
        t.title = req.title;
        t.description = req.description;
        t.assignee = req.assignee;
        t.creator = req.creator;
        t.sourceApplication = req.sourceApplication;
        t.dueDate = req.dueDate;
        t.createdBy = req.createdBy;
        repo.save(req.tenantId, t);
        return CommandResult(true, req.id, "");
    }

    CommandResult update(UpdateTaskRequest req) {
        auto existing = repo.findById(req.tenantId, req.id);
        if (existing == Task.init)
            return CommandResult(false, "", "Task not found");
        if (req.title.length > 0) existing.title = req.title;
        if (req.description.length > 0) existing.description = req.description;
        if (req.assignee.length > 0) existing.assignee = req.assignee;
        if (req.dueDate.length > 0) existing.dueDate = req.dueDate;
        existing.modifiedBy = req.modifiedBy;
        repo.update(req.tenantId, existing);
        return CommandResult(true, req.id, "");
    }

    CommandResult claim(string tenantId, string id, string userId) {
        auto t = repo.findById(tenantId, id);
        if (t == Task.init)
            return CommandResult(false, "", "Task not found");
        t.isClaimed = true;
        t.claimedBy = userId;
        t.status = TaskStatus.inProgress;
        t.processor = userId;
        repo.update(tenantId, t);
        return CommandResult(true, id.toString, "");
    }

    CommandResult release(string tenantId, string id) {
        auto t = repo.findById(tenantId, id);
        if (t == Task.init)
            return CommandResult(false, "", "Task not found");
        t.isClaimed = false;
        t.claimedBy = "";
        t.status = TaskStatus.open;
        t.processor = "";
        repo.update(tenantId, t);
        return CommandResult(true, id.toString, "");
    }

    CommandResult forward(string tenantId, string id, string toUser, string comment) {
        auto t = repo.findById(tenantId, id);
        if (t == Task.init)
            return CommandResult(false, "", "Task not found");
        t.assignee = toUser;
        t.status = TaskStatus.forwarded;
        repo.update(tenantId, t);
        return CommandResult(true, id.toString, "");
    }

    CommandResult complete(string tenantId, string id) {
        auto t = repo.findById(tenantId, id);
        if (t == Task.init)
            return CommandResult(false, "", "Task not found");
        t.status = TaskStatus.completed;
        repo.update(tenantId, t);
        return CommandResult(true, id.toString, "");
    }

    CommandResult cancel(string tenantId, string id) {
        auto t = repo.findById(tenantId, id);
        if (t == Task.init)
            return CommandResult(false, "", "Task not found");
        t.status = TaskStatus.cancelled;
        repo.update(tenantId, t);
        return CommandResult(true, id.toString, "");
    }

    CommandResult remove(string tenantId, string id) {
        repo.remove(tenantId, id);
        return CommandResult(true, id.toString, "");
    }
}
