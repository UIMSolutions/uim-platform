/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.controllers.configuration;

import uim.platform.redis;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebConfigurationController {
    private WebConfigurationModel  _model;
    private WebConfigurationView   _view;
    private ManageConfigurationsUseCase _useCase;

    this(ManageConfigurationsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebConfigurationModel();
        _view    = new WebConfigurationView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/redis/configurations",    &handleList);
        router.get("/web/redis/configurations/*",  &handleDetail);
        router.post("/web/redis/configurations",   &handleCreate);
        router.post("/web/redis/configurations/*", &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        _model.setConfigurations(_useCase.listConfigurations(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
        auto c = _useCase.getConfiguration(tenantId, id);
        _model.setSelected(c, !c.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        ConfigurationDTO dto;
        dto.tenantId        = tenantId;
        dto.instanceId      = ServiceInstanceId(data.getString("instanceId", ""));
        dto.maxMemoryPolicy = MaxMemoryPolicy.allkeys_lru;
        dto.persistenceMode = PersistenceMode.none;
        auto result = _useCase.createConfiguration(dto);
        if (result.success) _model.setSuccess("Configuration created: " ~ result.id);
        else                _model.setError(400, result.error);
        _model.setConfigurations(_useCase.listConfigurations(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteConfiguration(tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(400, result.error);
        _model.setConfigurations(_useCase.listConfigurations(tenantId));
        _view.renderList(res, _model);
    }
}
