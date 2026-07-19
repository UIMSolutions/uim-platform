/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.service_plan;

import uim.platform.postgres;
mixin(ShowModule!());

@safe:

class GuiServicePlanController {
    private GuiServicePlanModel   _model;
    private GuiServicePlanView    _view;
    private ManageServicePlansUseCase _useCase;

    this(ManageServicePlansUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiServicePlanModel();
        _view    = new GuiServicePlanView();
    }

    Json listPlans(TenantId tenantId) {
        _model.setPlans(_useCase.listServicePlans(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getPlan(TenantId tenantId, ServicePlanId id) {
        auto p = _useCase.getServicePlan(tenantId, id);
        _model.setSelected(p, !p.isNull);
        return _view.buildDetailDescriptor(_model);
    }
}
