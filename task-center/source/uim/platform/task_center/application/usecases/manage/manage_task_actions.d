/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.task_actions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskActionsUseCase : UIMUseCase {
    private TaskActionRepository repo;

    this(TaskActionRepository repo) {
        this.repo = repo;
    }

    TaskAction get_(string tenantId, string id) {
        return repo.findById(tenantId, id);
    }

    TaskAction[] listByTask(string tenantId, string taskId) {
        return repo.findByTask(tenantId, taskId);
    }

    TaskAction[] listByPerformer(string tenantId, string performerId) {
        return repo.findByPerformer(tenantId, performerId);
    }

    CommandResult create(PerformTaskActionRequest req) {
        TaskAction a;
        a.id = req.id;
        a.tenantId = req.tenantId;
        a.taskId = req.taskId;
        a.performedBy = req.performedBy;
        a.forwardTo = req.forwardTo;
        a.comment = req.comment;
        repo.save(req.tenantId, a);
        return CommandResult(true, req.id, "");
    }

    CommandResult remove(string tenantId, string id) {
        repo.remove(tenantId, id);
        return CommandResult(true, id.toString, "");
    }
}
