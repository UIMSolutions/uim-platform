/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.models.task;

import uim.platform.workzone;

@safe:
/// Observable GUI model for the task inbox.
final class TaskGuiModel {
    private WZTask[] _tasks;
    private ManageTasksUseCase _useCase;
    private string _tenantId;
    private string _assigneeId;

    void delegate() @safe onChanged;

    this(ManageTasksUseCase useCase, string tenantId, string assigneeId = "") {
        _useCase    = useCase;
        _tenantId   = tenantId;
        _assigneeId = assigneeId;
    }

    @property const(WZTask[]) items() const { return _tasks; }

    size_t count() const { return _tasks.length; }

    size_t overdueCount() const {
        import std.datetime : Clock;
        size_t n;
        immutable now = Clock.currTime.toUnixTime();
        foreach (t; _tasks) {
            if (t.dueDate > 0 && t.dueDate < now &&
                t.status != TaskStatus.completed &&
                t.status != TaskStatus.cancelled)
                n++;
        }
        return n;
    }

    void setAssignee(string assigneeId) {
        _assigneeId = assigneeId;
        refresh();
    }

    void refresh() {
        if (_assigneeId.length > 0)
            _tasks = _useCase.listByAssignee(_tenantId, UserId(_assigneeId));
        else
            _tasks = _useCase.listTasks(_tenantId);
        if (onChanged !is null) onChanged();
    }

    CommandResult completeTask(string id) {
        auto result = _useCase.updateTaskStatus(
            _tenantId, TaskId(id), TaskStatus.completed);
        if (result.success) refresh();
        return result;
    }

    string titleAt(size_t i) const {
        return i < _tasks.length ? _tasks[i].title : "";
    }
    string statusAt(size_t i) const {
        return i < _tasks.length ? _tasks[i].status.to!string : "";
    }
    string priorityAt(size_t i) const {
        return i < _tasks.length ? _tasks[i].priority.to!string : "";
    }
}
