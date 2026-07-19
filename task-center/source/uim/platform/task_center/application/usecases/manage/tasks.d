/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTasksUseCase { // TODO: UIMUseCase {
    private TaskRepository repo;

    this(TaskRepository repo) {
        this.repo = repo;
    }

    UIMTask getTask(TenantId tenantId, TaskId id) {
        return repo.findById(tenantId, id);
    }

    UIMTask[] listTasks(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UIMTask[] listTasks(TenantId tenantId, string byAssignee) {
        return repo.findByAssignee(tenantId, byAssignee);
    }

    UIMTask[] listTasks(TenantId tenantId, TaskStatus byStatus) {
        return repo.findByStatus(tenantId, byStatus);
    }

    UIMTask[] listTasks(TenantId tenantId, TaskProviderId byProviderId) {
        return repo.findByProvider(tenantId, byProviderId);
    }

    UIMTask[] listTasks(TenantId tenantId, TaskCategory byCategory) {
        return repo.findByCategory(tenantId, byCategory);
    }

    UIMTask[] listTasks(TenantId tenantId, TaskPriority byPriority) {
        return repo.findByPriority(tenantId, byPriority);
    }

    CommandResult createTask(CreateTaskRequest req) {
        if (!TaskValidator.validate(req.taskId.value, req.title))
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
        auto task = repo.findById(req.tenantId, req.taskId);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");
            
        if (req.title.length > 0) task.title = req.title;
        if (req.description.length > 0) task.description = req.description;
        if (req.assignee.length > 0) task.assignee = req.assignee;
        if (req.dueDate.length > 0) task.dueDate = req.dueDate;
        task.updatedBy = req.updatedBy;

        repo.update(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult claimTask(TenantId tenantId, TaskId id, UserId userId) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.isClaimed = true;
        task.claimedBy = userId;
        task.status = TaskStatus.inProgress;
        task.processor = userId.value;

        repo.update(task);
        return CommandResult(true, id.value, "");
    }

    CommandResult releaseTask(TenantId tenantId, TaskId id) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.isClaimed = false;
        task.claimedBy = UserId.init;
        task.status = TaskStatus.open;
        task.processor = "";

        repo.update(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult forwardTask(TenantId tenantId, TaskId id, UserId toUser, string comment) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.assignee = toUser.value;
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
