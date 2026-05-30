/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.service_binding;

import uim.platform.postgres;


mixin(ShowModule!());

@safe:

class WebServiceBindingController {
    private WebServiceBindingModel   _model;
    private WebServiceBindingView    _view;
    private ManageServiceBindingsUseCase _useCase;

    this(ManageServiceBindingsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebServiceBindingModel();
        _view    = new WebServiceBindingView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/bindings",     &handleList);
        router.get("/web/postgres/bindings/*",   &handleDetail);
        router.post("/web/postgres/bindings",    &handleCreate);
        router.post("/web/postgres/bindings/*",  &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listServiceBindings(tenantId);
        _model.setBindings(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = ServiceBindingId(precheck.id);
        auto b  = _useCase.getServiceBinding(tenantId, id);
        _model.setSelected(b, !b.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        ServiceBindingDTO dto;
        dto.tenantId   = tenantId;
        dto.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
        dto.appId      = data.getString("appId", "");
        auto result = _useCase.createServiceBinding(dto);
        if (result.success) _model.setSuccess("Binding created: " ~ result.id);
        else                _model.setError(400, result.message);
        auto list = _useCase.listServiceBindings(tenantId);
        _model.setBindings(list);
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = ServiceBindingId(precheck.id);
        auto result = _useCase.deleteServiceBinding(tenantId, id);
        if (result.success) _model.setSuccess("Binding deleted");
        else                _model.setError(404, result.message);
        auto list = _useCase.listServiceBindings(tenantId);
        _model.setBindings(list);
        _view.renderList(res, _model);
    }
}
