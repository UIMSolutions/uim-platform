/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.service_plan;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class GuiServicePlanController {
    private GuiServicePlanModel  _model;
    private GuiServicePlanView   _view;
    private ManageServicePlansUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageServicePlansUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase = useCase; _tenantId = precheck.tenantId;
        _model = new GuiServicePlanModel(); _view = new GuiServicePlanView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = precheck.tenantId; }
    GuiServicePlanModel model() { return _model; }

    Json loadList() {
        _model.setPlans(_useCase.listServicePlans(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json loadDetail(ServicePlanId id) {
        auto p = _useCase.getServicePlan(_tenantId, id);
        _model.setSelected(p, !p.isNull);
        return _view.buildDetailDescriptor(_model);
    }
}
