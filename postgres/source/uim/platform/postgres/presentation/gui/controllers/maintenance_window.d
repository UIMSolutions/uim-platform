/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.maintenance_window;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiMaintenanceWindowController {
    private GuiMaintenanceWindowModel   _model;
    private GuiMaintenanceWindowView    _view;
    private ManageMaintenanceWindowsUseCase _useCase;

    this(ManageMaintenanceWindowsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiMaintenanceWindowModel();
        _view    = new GuiMaintenanceWindowView();
    }

    Json listWindows(TenantId tenantId) {
        _model.setWindows(_useCase.listMaintenanceWindows(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getWindow(TenantId tenantId, MaintenanceWindowId id) {
        auto w = _useCase.getMaintenanceWindow(tenantId, id);
        _model.setSelected(w, !w.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json createWindow(TenantId tenantId, MaintenanceWindowDTO dto) {
        auto result = _useCase.createMaintenanceWindow(dto);
        if (result.success) _model.setSuccess("Window created: " ~ result.id);
        else                _model.setError(result.error);
        _model.setWindows(_useCase.listMaintenanceWindows(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json deleteWindow(TenantId tenantId, MaintenanceWindowId id) {
        auto result = _useCase.deleteMaintenanceWindow(tenantId, id);
        if (result.success) _model.setSuccess("Window deleted");
        else                _model.setError(result.error);
        _model.setWindows(_useCase.listMaintenanceWindows(tenantId));
        return _view.buildListDescriptor(_model);
    }
}
