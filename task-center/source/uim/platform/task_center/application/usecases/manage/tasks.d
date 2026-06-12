/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.tasks;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class ManageTasksUseCase { // TODO: UIMUseCase {
    private TaskRepository repo;

    this(TaskRepository repo) {
        this.repo = repo;
    }

    UIMTask getTaskById(TenantId tenantId, TaskId id) {
        return repo.findById(tenantId, id);
    }

    UIMTask[] listTasks(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UIMTask[] listTasksByAssignee(TenantId tenantId, string assignee) {
        return repo.findByAssignee(tenantId, assignee);
    }

    UIMTask[] listTasksByStatus(TenantId tenantId, TaskStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    UIMTask[] listTasksByProvider(TenantId tenantId, TaskProviderId providerId) {
        return repo.findByProvider(tenantId, providerId);
    }

    UIMTask[] listTasksByCategory(TenantId tenantId, TaskCategory category) {
        return repo.findByCategory(tenantId, category);
    }

    UIMTask[] listTasksByPriority(TenantId tenantId, TaskPriority priority) {
        return repo.findByPriority(tenantId, priority);
    }

    CommandResult createTask(CreateTaskRequest req) {
        if (!TaskValidator.validate(req.taskId, req.title))
            return CommandResult(false, "", "Invalid task data");
        
        auto task = UIMTask(req.tenantId);
        task.id = req.taskId;

        task.definitionId = req.definitionId;
        task.providerId = req.providerId;
        task.externalTaskId = req.externalTaskId;
        task.title = req.title;
        task.description = req.description;
        task.assignee = req.assignee;
        task.creator = req.creator;
        task.sourceApplication = req.sourceApplication;
        task.dueDate = req.dueDate;
        task.createdBy = req.createdBy;

        repo.save(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult updateTask(UpdateTaskRequest req) {
        auto existing = repo.findById(req.tenantId, req.taskId);
        if (existing.isNull)
            return CommandResult(false, "", "Task not found");
            
        if (req.title.length > 0) existing.title = req.title;
        if (req.description.length > 0) existing.description = req.description;
        if (req.assignee.length > 0) existing.assignee = req.assignee;
        if (req.dueDate.length > 0) existing.dueDate = req.dueDate;
        existing.updatedBy = req.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult claim(TenantId tenantId, TaskId id, UserId userId) {
        auto t = repo.findById(tenantId, id);
        if (t.isNull)
            return CommandResult(false, "", "Task not found");

        t.isClaimed = true;
        t.claimedBy = userId;
        t.status = TaskStatus.inProgress;
        t.processor = userId;

        repo.update(tenantId, t);
        return CommandResult(true, id.value, "");
    }

    CommandResult releaseTask(TenantId tenantId, TaskId id) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.isClaimed = false;
        task.claimedBy = UserId.init;
        task.status = TaskStatus.open;
        task.processor = UserId.init;

        repo.update(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult forwardTask(TenantId tenantId, TaskId id, UserId toUser, string comment) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.assignee = toUser;
        task.status = TaskStatus.forwarded;

        repo.update(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult completeTask(TenantId tenantId, TaskId id) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.status = TaskStatus.completed;
        
        repo.update(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult cancelTask(TenantId tenantId, TaskId id) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.status = TaskStatus.cancelled;

        repo.update(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult deleteTask(TenantId tenantId, TaskId id) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        repo.remove(task);
        return CommandResult(true, task.id.value, "");
    }
}
