module application.usecases.manage_tasks;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.task;
import uim.platform.xyz.domain.ports.task_repository;
import uim.platform.xyz.application.dto;

class ManageTasksUseCase
{
    private TaskRepository repo;

    this(TaskRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createTask(CreateTaskRequest req)
    {
        if (req.title.length == 0)
            return CommandResult("", "Task title is required");

        auto now = Clock.currStdTime();
        auto t = Task();
        t.id = randomUUID().toString();
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

    Task* getTask(TaskId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    Task[] listByAssignee(UserId assigneeId, TenantId tenantId)
    {
        return repo.findByAssignee(assigneeId, tenantId);
    }

    Task[] listByStatus(TaskStatus status, UserId assigneeId, TenantId tenantId)
    {
        return repo.findByStatus(status, assigneeId, tenantId);
    }

    CommandResult updateTask(UpdateTaskRequest req)
    {
        auto t = repo.findById(req.id, req.tenantId);
        if (t is null)
            return CommandResult("", "Task not found");

        if (req.title.length > 0) t.title = req.title;
        if (req.description.length > 0) t.description = req.description;
        t.status = req.status;
        t.priority = req.priority;
        if (req.dueDate > 0) t.dueDate = req.dueDate;
        t.updatedAt = Clock.currStdTime();

        if (t.status == TaskStatus.completed && t.completedAt == 0)
            t.completedAt = Clock.currStdTime();

        repo.update(*t);
        return CommandResult(t.id, "");
    }

    CommandResult completeTask(TaskId id, TenantId tenantId)
    {
        auto t = repo.findById(id, tenantId);
        if (t is null)
            return CommandResult("", "Task not found");

        t.status = TaskStatus.completed;
        t.completedAt = Clock.currStdTime();
        t.updatedAt = Clock.currStdTime();
        repo.update(*t);
        return CommandResult(t.id, "");
    }

    void deleteTask(TaskId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
