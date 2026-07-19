/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.metric;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class GuiMetricController {
    private GuiMetricModel  _model;
    private GuiMetricView   _view;
    private ManageMetricsUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageMetricsUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase = useCase; _tenantId = tenantId;
        _model = new GuiMetricModel(); _view = new GuiMetricView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = tenantId; }
    GuiMetricModel model() { return _model; }

    Json loadList() {
        _model.setMetrics(_useCase.listMetrics(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json loadDetail(MetricId id) {
        auto m = _useCase.getMetric(_tenantId, id);
        _model.setSelected(m, !m.isNull);
        return _view.buildDetailDescriptor(_model);
    }
}
