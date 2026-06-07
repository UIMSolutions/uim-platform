/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.controllers.metric;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class CliMetricController {
    private CliMetricModel  _model;
    private CliMetricView   _view;
    private ManageMetricsUseCase _useCase;

    this(ManageMetricsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliMetricModel();
        _view    = new CliMetricView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list": handleList(tenantId, args[1..$]); break;
            case "get":  handleGet(tenantId, args[1..$]);  break;
            default:     _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listMetrics(tenantId);
        _model.setMetrics(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto m = _useCase.getMetric(tenantId, MetricId(args[0]));
        _model.setSelected(m, !m.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }
}
