/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.tasks;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageTasksUseCase { // TODO: UIMUseCase {
    private TaskRepository repo;

    this(TaskRepository repo) {
        this.repo = repo;
    }

    CommandResult createTask(CreateTaskRequest r) {
        auto err = ProcessValidator.validateTask(r.tenantId, r.taskId, r.name, r.assignee);
        if (err.length > 0)
            return CommandResult(false, "", err);

        PATask t;
        t.initEntity(r.tenantId); // TODO: createdBy);
        t.id = r.taskId;
        t.processInstanceId = r.processInstanceId;
        t.name = r.name;
        t.description = r.description;
        t.status = TaskStatus.ready;
        t.assignee = r.assignee;
        t.candidateUsers = r.candidateUsers.map!(u => UserId(u)).array.toJson;
        t.candidateGroups = r.candidateGroups;
        t.formId = r.formId;
        t.dueDate = r.dueDate;

        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    PATask getTask(TenantId tenantId, TaskId id) {
        return repo.findById(tenantId, id);
    }

    PATask[] listTasks(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    PATask[] listTasksByAssignee(TenantId tenantId, UserId assignee) {
        return repo.findByAssignee(tenantId, assignee);
    }

    PATask[] listTasksByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId) {
        return repo.findByProcessInstance(tenantId, instanceId);
    }

    CommandResult claimTask(ClaimTaskRequest r) {
        auto existing = repo.findById(r.tenantId, r.taskId);
        if (existing.isNull)
            return CommandResult(false, "", "Task not found");

        if (existing.status != TaskStatus.ready)
            return CommandResult(false, "", "Task cannot be claimed in current state");

        existing.assignee = r.userId;
        existing.status = TaskStatus.reserved;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult completeTask(CompleteTaskRequest r) {
        auto existing = repo.findById(r.tenantId, r.taskId);
        if (existing.isNull)
            return CommandResult(false, "", "Task not found");

        existing.status = TaskStatus.completed;
        existing.completedBy = r.completedBy;
        existing.outcome = r.outcome;
        existing.formData = r.formData;

        import core.time : MonoTime;
        existing.completedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult updateTask(UpdateTaskRequest r) {
        auto task = repo.findById(r.tenantId, r.taskId);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        task.name = r.name;
        task.description = r.description;
        task.assignee = r.assignee;
        task.dueDate = r.dueDate;

        repo.update(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult deleteTask(TenantId tenantId, TaskId taskId) {
        auto task = repo.findById(tenantId, taskId);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        repo.remove(task);
        return CommandResult(true, task.id.value, "");
    }
}
