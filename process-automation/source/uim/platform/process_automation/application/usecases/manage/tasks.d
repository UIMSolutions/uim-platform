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
        auto err = ProcessValidator.validateTask(r.name, r.assignee);
        if (err.length > 0)
            return CommandResult(false, "", err);

        Task t;
        t.id = r.id;
        t.processInstanceId = r.processInstanceId;
        t.tenantId = r.tenantId;
        t.name = r.name;
        t.description = r.description;
        t.status = TaskStatus.ready;
        t.assignee = r.assignee;
        t.candidateUsers = r.candidateUsers;
        t.candidateGroups = r.candidateGroups;
        t.formId = r.formId;
        t.dueDate = r.dueDate;

        import core.time : MonoTime;
        t.createdAt = MonoTime.currTime.ticks;

        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    Task getTask(TaskId id) {
        return repo.findById(tenantId, id);
    }

    Task[] listTasks(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Task[] listTasksByAssignee(TenantId tenantId, string assignee) {
        return repo.findByAssignee(tenantId, assignee);
    }

    Task[] listTasksByProcessInstance(ProcessInstanceId instanceId) {
        return repo.findByProcessInstance(instanceId);
    }

    CommandResult claimTask(ClaimTaskRequest r) {
        auto existing = repo.findById(r.id);
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
        auto existing = repo.findById(r.id);
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
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Task not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.assignee = r.assignee;
        existing.dueDate = r.dueDate;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteTask(TaskId id) {
        auto task = repo.findById(tenantId, id);
        if (task.isNull)
            return CommandResult(false, "", "Task not found");

        repo.remove(task);
        return CommandResult(true, id.value, "");
    }
}
