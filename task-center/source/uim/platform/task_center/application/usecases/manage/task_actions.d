/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.task_actions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskActionsUseCase { // TODO: UIMUseCase {
    private TaskActionRepository repo;

    this(TaskActionRepository repo) {
        this.repo = repo;
    }

    TaskAction getAction(TenantId tenantId, TaskActionId actionId) {
        return repo.findById(tenantId, actionId);
    }

    TaskAction[] listActions(TenantId tenantId, TaskId byTaskId) {
        return repo.findByTask(tenantId, byTaskId);
    }

    TaskAction[] listActions(TenantId tenantId, UserId byPerformerId) {
        return repo.findByPerformer(tenantId, byPerformerId);
    }

    CommandResult createAction(PerformTaskActionRequest req) {
        auto action = TaskAction(req.tenantId, req.actionId, req.createdBy);
        action.taskId = req.taskId;
        action.performedBy = req.performedBy;
        action.forwardTo = req.forwardTo;
        action.comment = req.comment;

        repo.save(action);
        return CommandResult(true, action.id.value, "");
    }

    CommandResult deleteAction(TenantId tenantId, TaskActionId id) {
        auto action = repo.findById(tenantId, id);
        if (action.isNull)
            return CommandResult(false, "", "Task action not found");

        repo.remove(action);
        return CommandResult(true, action.id.value, "");
    }
}
