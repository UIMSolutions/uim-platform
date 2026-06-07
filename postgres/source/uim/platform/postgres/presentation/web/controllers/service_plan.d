/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.service_plan;

import uim.platform.postgres;


// mixin(ShowModule!());

@safe:

class WebServicePlanController {
    private WebServicePlanModel   _model;
    private WebServicePlanView    _view;
    private ManageServicePlansUseCase _useCase;

    this(ManageServicePlansUseCase useCase) {
        _useCase = useCase;
        _model   = new WebServicePlanModel();
        _view    = new WebServicePlanView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/plans",     &handleList);
        router.get("/web/postgres/plans/*",   &handleDetail);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listServicePlans(tenantId);
        _model.setPlans(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = ServicePlanId(precheck.id);
        auto p  = _useCase.getServicePlan(tenantId, id);
        _model.setSelected(p, !p.isNull);
        _view.renderDetail(res, _model);
    }
}
