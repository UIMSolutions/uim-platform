/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.service_instance;

import uim.platform.postgres;


// mixin(ShowModule!());

@safe:

class WebServiceInstanceController {
    private WebServiceInstanceModel   _model;
    private WebServiceInstanceView    _view;
    private ManageServiceInstancesUseCase _useCase;

    this(ManageServiceInstancesUseCase useCase) {
        _useCase = useCase;
        _model   = new WebServiceInstanceModel();
        _view    = new WebServiceInstanceView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/instances",     &handleList);
        router.get("/web/postgres/instances/*",   &handleDetail);
        router.post("/web/postgres/instances",    &handleCreate);
        router.post("/web/postgres/instances/*",  &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listServiceInstances(tenantId);
        _model.setInstances(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id  = ServiceInstanceId(precheck.id);
        auto inst = _useCase.getServiceInstance(tenantId, id);
        _model.setSelected(inst, !inst.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        ServiceInstanceDTO dto;
        dto.tenantId  = tenantId;
        dto.name      = data.getString("name", "");
        dto.planId    = ServicePlanId(data.getString("planId", ""));
        dto.memoryGb  = data.getLong("memoryGb", 4);
        dto.sslEnabled = data.getBoolean("sslEnabled", true);
        auto result = _useCase.createServiceInstance(dto);
        if (result.success) _model.setSuccess("Instance created: " ~ result.id);
        else                _model.setError(400, result.message);
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id  = ServiceInstanceId(precheck.id);
        auto result = _useCase.deleteServiceInstance(tenantId, id);
        if (result.success) _model.setSuccess("Instance deleted");
        else                _model.setError(404, result.message);
        auto list = _useCase.listServiceInstances(tenantId);
        _model.setInstances(list);
        _view.renderList(res, _model);
    }
}
