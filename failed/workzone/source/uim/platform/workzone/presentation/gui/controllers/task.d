/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.controllers.task;

import uim.platform.workzone;
import uim.platform.workzone.presentation.gui.models.task;

@safe:
/// GUI controller that mediates task interactions from the view to the model.
class TaskGuiController {
    private TaskGuiModel _model;

    this(TaskGuiModel model) {
        _model = model;
    }

    void setAssignee(string assigneeId) {
        _model.setAssignee(assigneeId);
    }

    void refresh() {
        _model.refresh();
    }

    CommandResult completeTask(string id) {
        return _model.completeTask(id);
    }

    size_t taskCount()   const { return _model.count(); }
    size_t overdueCount() const { return _model.overdueCount(); }
}
