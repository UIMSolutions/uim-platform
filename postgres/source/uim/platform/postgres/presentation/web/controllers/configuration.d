/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.configuration;

import uim.platform.postgres;


// mixin(ShowModule!());

@safe:

class WebConfigurationController {
    private WebConfigurationModel   _model;
    private WebConfigurationView    _view;
    private ManageConfigurationsUseCase _useCase;

    this(ManageConfigurationsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebConfigurationModel();
        _view    = new WebConfigurationView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/configurations",   &handleList);
        router.get("/web/postgres/configurations/*", &handleDetail);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listConfigurations(tenantId);
        _model.setConfigurations(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = ConfigurationId(precheck.id);
        auto c  = _useCase.getConfiguration(tenantId, id);
        _model.setSelected(c, !c.isNull);
        _view.renderDetail(res, _model);
    }
}
