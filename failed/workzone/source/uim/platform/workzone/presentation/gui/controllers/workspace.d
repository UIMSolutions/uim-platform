/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.controllers.workspace;

import uim.platform.workzone;
import uim.platform.workzone.presentation.gui.models.workspace;
import uim.platform.workzone.presentation.gui.models.workpage;

@safe:
/// GUI controller that handles workspace-level actions and bridges the
/// workspace model to the workpage panel model.
class WorkspaceGuiController {
    private WorkspaceGuiModel _workspaceModel;
    private WorkpageGuiModel  _workpageModel;

    this(WorkspaceGuiModel workspaceModel, WorkpageGuiModel workpageModel) {
        _workspaceModel = workspaceModel;
        _workpageModel  = workpageModel;

        // When a workspace is selected, load its pages
        _workspaceModel.onChanged = () {
            if (_workspaceModel.count > 0)
                _workpageModel.setWorkspace(_workspaceModel.idAt(0));
        };
    }

    /// Called when the user selects a workspace row.
    void onWorkspaceSelected(size_t index) {
        if (index < _workspaceModel.count)
            _workpageModel.setWorkspace(_workspaceModel.idAt(index));
    }

    /// Delegate a create request from the view.
    CommandResult createWorkspace(string name, string description,
                                  string alias_, WorkspaceType type) {
        return _workspaceModel.createWorkspace(name, description, alias_, type);
    }

    /// Delegate a remove request from the view.
    CommandResult removeWorkspace(string id) {
        return _workspaceModel.removeWorkspace(id);
    }
}
