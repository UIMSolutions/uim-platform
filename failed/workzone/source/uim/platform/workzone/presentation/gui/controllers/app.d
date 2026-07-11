/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.controllers.app;

version (Have_gtkd):

import gtk.Application : Application;
import gio.ApplicationFlags;

import uim.platform.workzone;
import uim.platform.workzone.presentation.gui.models.workspace;
import uim.platform.workzone.presentation.gui.models.workpage;
import uim.platform.workzone.presentation.gui.models.task;
import uim.platform.workzone.presentation.gui.views.main_window;

/// Root GUI application controller.
/// Bootstraps the GTK Application, wires models, and launches the main window.
class WorkZoneAppController {
    private Application         _app;
    private WorkspaceGuiModel   _workspaceModel;
    private WorkpageGuiModel    _workpageModel;
    private TaskGuiModel        _taskModel;

    this(ManageWorkspacesUseCase workspacesUC,
         ManageWorkpagesUseCase  workpagesUC,
         ManageTasksUseCase      tasksUC,
         TenantId tenantId) {
        _workspaceModel = new WorkspaceGuiModel(workspacesUC, tenantId);
        _workpageModel  = new WorkpageGuiModel(workpagesUC, tenantId, "");
        _taskModel      = new TaskGuiModel(tasksUC, tenantId);

        _app = new Application("org.uim.workzone",
                               ApplicationFlags.FLAGS_NONE);
        _app.addOnActivate((_) { onActivate(); });
    }

    /// Run the GTK event loop. Returns exit code.
    int run(string[] args) {
        return _app.run(args);
    }

    private void onActivate() {
        auto win = new WorkZoneWindow(_app, _workspaceModel, _taskModel);
        win.present();
    }
}
