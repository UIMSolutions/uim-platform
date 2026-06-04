/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.models.task;

import uim.platform.workzone;

@safe:
/// CLI model for task inbox operations.
struct TaskCliModel {
    private ManageTasksUseCase _useCase;
    private TenantId _tenantId;

    this(ManageTasksUseCase useCase, TenantId tenantId) {
        _useCase  = useCase;
        _tenantId = precheck.tenantId;
    }

    WZTask[] list()                           { return _useCase.listTasks(_tenantId); }
    WZTask[] listByAssignee(string assigneeId){ return _useCase.listByAssignee(_tenantId, UserId(assigneeId)); }
    WZTask[] listByStatus(string statusStr) {
        return _useCase.listByStatus(_tenantId, parseStatus(statusStr), UserId(""));
    }

    WZTask get(string id) {
        return _useCase.getTask(_tenantId, TaskId(id));
    }

    CommandResult complete(string id) {
        return _useCase.completeTask(_tenantId, TaskId(id));
    }

    private static TaskStatus parseStatus(string s) @safe pure {
        switch (s) {
            case "inProgress": return TaskStatus.inProgress;
            case "completed":  return TaskStatus.completed;
            case "cancelled":  return TaskStatus.cancelled;
            default:           return TaskStatus.open;
        }
    }
}
