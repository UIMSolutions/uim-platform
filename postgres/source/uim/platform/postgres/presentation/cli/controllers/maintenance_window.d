/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.controllers.maintenance_window;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class CliMaintenanceWindowController {
    private CliMaintenanceWindowModel   _model;
    private CliMaintenanceWindowView    _view;
    private ManageMaintenanceWindowsUseCase _useCase;

    this(ManageMaintenanceWindowsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliMaintenanceWindowModel();
        _view    = new CliMaintenanceWindowView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":   handleList(tenantId, args[1..$]);   break;
            case "get":    handleGet(tenantId, args[1..$]);    break;
            case "create": handleCreate(tenantId, args[1..$]); break;
            case "delete": handleDelete(tenantId, args[1..$]); break;
            default:       _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listMaintenanceWindows(tenantId);
        _model.setWindows(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto w = _useCase.getMaintenanceWindow(tenantId, MaintenanceWindowId(args[0]));
        _model.setSelected(w, !w.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <instanceId> <day>"); return; }
        MaintenanceWindowDTO dto;
        dto.tenantId              = tenantId;
        dto.instanceId            = ServiceInstanceId(args[0]);
        dto.dayOfWeek             = args[1];
        dto.startHourUtc          = 2;
        dto.durationHours         = 1;
        dto.autoMinorVersionUpgrade = true;
        auto result = _useCase.createMaintenanceWindow(dto);
        if (result.success) _view.renderSuccess("Created maintenance window: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteMaintenanceWindow(tenantId, MaintenanceWindowId(args[0]));
        if (result.success) _view.renderSuccess("Deleted maintenance window: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
