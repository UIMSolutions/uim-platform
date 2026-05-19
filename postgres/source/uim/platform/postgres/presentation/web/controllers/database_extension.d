/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.database_extension;

import uim.platform.postgres;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebDatabaseExtensionController {
    private WebDatabaseExtensionModel   _model;
    private WebDatabaseExtensionView    _view;
    private ManageDatabaseExtensionsUseCase _useCase;

    this(ManageDatabaseExtensionsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebDatabaseExtensionModel();
        _view    = new WebDatabaseExtensionView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/extensions",     &handleList);
        router.get("/web/postgres/extensions/*",   &handleDetail);
        router.post("/web/postgres/extensions",    &handleCreate);
        router.post("/web/postgres/extensions/*",  &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listDatabaseExtensions(tenantId);
        _model.setExtensions(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = DatabaseExtensionId(extractIdFromPath(req.requestURI.to!string));
        auto e  = _useCase.getDatabaseExtension(tenantId, id);
        _model.setSelected(e, !e.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        DatabaseExtensionDTO dto;
        dto.tenantId      = tenantId;
        dto.instanceId    = ServiceInstanceId(data.getString("instanceId", ""));
        dto.extensionName = data.getString("extensionName", "");
        dto.schema_       = data.getString("schema", "public");
        auto result = _useCase.createDatabaseExtension(dto);
        if (result.success) _model.setSuccess("Extension enabled: " ~ result.id);
        else                _model.setError(400, result.error);
        auto list = _useCase.listDatabaseExtensions(tenantId);
        _model.setExtensions(list);
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = DatabaseExtensionId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteDatabaseExtension(tenantId, id);
        if (result.success) _model.setSuccess("Extension disabled");
        else                _model.setError(404, result.error);
        auto list = _useCase.listDatabaseExtensions(tenantId);
        _model.setExtensions(list);
        _view.renderList(res, _model);
    }
}
