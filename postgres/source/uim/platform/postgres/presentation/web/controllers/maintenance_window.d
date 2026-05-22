/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.maintenance_window;

import uim.platform.postgres;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebMaintenanceWindowController {
    private WebMaintenanceWindowModel   _model;
    private WebMaintenanceWindowView    _view;
    private ManageMaintenanceWindowsUseCase _useCase;

    this(ManageMaintenanceWindowsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebMaintenanceWindowModel();
        _view    = new WebMaintenanceWindowView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/maintenance-windows",     &handleList);
        router.get("/web/postgres/maintenance-windows/*",   &handleDetail);
        router.post("/web/postgres/maintenance-windows",    &handleCreate);
        router.post("/web/postgres/maintenance-windows/*",  &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listMaintenanceWindows(tenantId);
        _model.setWindows(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = MaintenanceWindowId(extractIdFromPath(req.requestURI.to!string));
        auto w  = _useCase.getMaintenanceWindow(tenantId, id);
        _model.setSelected(w, !w.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        MaintenanceWindowDTO dto;
        dto.tenantId    = tenantId;
        dto.instanceId  = ServiceInstanceId(data.getString("instanceId", ""));
        dto.dayOfWeek   = data.getString("dayOfWeek", "Sunday");
        dto.startHourUtc = data.getLong("startHourUtc", 2);
        dto.durationHours = data.getLong("durationHours", 1);
        auto result = _useCase.createMaintenanceWindow(dto);
        if (result.success) _model.setSuccess("Window created: " ~ result.id);
        else                _model.setError(400, result.message);
        auto list = _useCase.listMaintenanceWindows(tenantId);
        _model.setWindows(list);
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = MaintenanceWindowId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteMaintenanceWindow(tenantId, id);
        if (result.success) _model.setSuccess("Window deleted");
        else                _model.setError(404, result.message);
        auto list = _useCase.listMaintenanceWindows(tenantId);
        _model.setWindows(list);
        _view.renderList(res, _model);
    }
}
