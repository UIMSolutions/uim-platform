/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.database_user;

import uim.platform.postgres;


mixin(ShowModule!());

@safe:

class WebDatabaseUserController {
    private WebDatabaseUserModel   _model;
    private WebDatabaseUserView    _view;
    private ManageDatabaseUsersUseCase _useCase;

    this(ManageDatabaseUsersUseCase useCase) {
        _useCase = useCase;
        _model   = new WebDatabaseUserModel();
        _view    = new WebDatabaseUserView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/db-users",     &handleList);
        router.get("/web/postgres/db-users/*",   &handleDetail);
        router.post("/web/postgres/db-users",    &handleCreate);
        router.post("/web/postgres/db-users/*",  &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listDatabaseUsers(tenantId);
        _model.setUsers(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = DatabaseUserId(precheck.id);
        auto u  = _useCase.getDatabaseUser(tenantId, id);
        _model.setSelected(u, !u.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        DatabaseUserDTO dto;
        dto.tenantId   = tenantId;
        dto.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
        dto.username   = data.getString("username", "");
        dto.roles      = data.getString("roles", "readonly");
        auto result = _useCase.createDatabaseUser(dto);
        if (result.success) _model.setSuccess("User created: " ~ result.id);
        else                _model.setError(400, result.message);
        auto list = _useCase.listDatabaseUsers(tenantId);
        _model.setUsers(list);
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = DatabaseUserId(precheck.id);
        auto result = _useCase.deleteDatabaseUser(tenantId, id);
        if (result.success) _model.setSuccess("User deleted");
        else                _model.setError(404, result.message);
        auto list = _useCase.listDatabaseUsers(tenantId);
        _model.setUsers(list);
        _view.renderList(res, _model);
    }
}
