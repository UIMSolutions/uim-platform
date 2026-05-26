/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.controllers.access_control;

import uim.platform.redis;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebAccessControlController {
    private WebAccessControlModel  _model;
    private WebAccessControlView   _view;
    private ManageAccessControlsUseCase _useCase;

    this(ManageAccessControlsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebAccessControlModel();
        _view    = new WebAccessControlView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/redis/access-controls",    &handleList);
        router.get("/web/redis/access-controls/*",  &handleDetail);
        router.post("/web/redis/access-controls",   &handleCreate);
        router.post("/web/redis/access-controls/*", &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        _model.setRules(_useCase.listAccessControls(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = AccessControlprecheck.id);
        auto a = _useCase.getAccessControl(tenantId, id);
        _model.setSelected(a, !a.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        AccessControlDTO dto;
        dto.tenantId   = tenantId;
        dto.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
        dto.cidr        = data.getString("cidr", "0.0.0.0/0");
        dto.description = data.getString("description", "");
        auto result = _useCase.createAccessControl(dto);
        if (result.success) _model.setSuccess("Rule created: " ~ result.id);
        else                _model.setError(400, result.message);
        _model.setRules(_useCase.listAccessControls(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = AccessControlprecheck.id);
        auto result = _useCase.deleteAccessControl(tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(400, result.message);
        _model.setRules(_useCase.listAccessControls(tenantId));
        _view.renderList(res, _model);
    }
}
