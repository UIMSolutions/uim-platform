/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.controllers.metric;

import uim.platform.redis;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebMetricController {
    private WebMetricModel  _model;
    private WebMetricView   _view;
    private ManageMetricsUseCase _useCase;

    this(ManageMetricsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebMetricModel();
        _view    = new WebMetricView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/redis/metrics",   &handleList);
        router.get("/web/redis/metrics/*", &handleDetail);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        _model.setMetrics(_useCase.listMetrics(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = Metricprecheck.id);
        auto m = _useCase.getMetric(tenantId, id);
        _model.setSelected(m, !m.isNull);
        _view.renderDetail(res, _model);
    }
}
