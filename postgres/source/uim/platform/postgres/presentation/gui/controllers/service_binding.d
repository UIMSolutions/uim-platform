/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.service_binding;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiServiceBindingController {
    private GuiServiceBindingModel   _model;
    private GuiServiceBindingView    _view;
    private ManageServiceBindingsUseCase _useCase;

    this(ManageServiceBindingsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiServiceBindingModel();
        _view    = new GuiServiceBindingView();
    }

    Json listBindings(TenantId tenantId) {
        _model.setBindings(_useCase.listServiceBindings(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getBinding(TenantId tenantId, ServiceBindingId id) {
        auto b = _useCase.getServiceBinding(tenantId, id);
        _model.setSelected(b, !b.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json createBinding(TenantId tenantId, ServiceBindingDTO dto) {
        auto result = _useCase.createServiceBinding(dto);
        if (result.success) _model.setSuccess("Binding created: " ~ result.id);
        else                _model.setError(result.errorMessage);
        _model.setBindings(_useCase.listServiceBindings(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json deleteBinding(TenantId tenantId, ServiceBindingId id) {
        auto result = _useCase.deleteServiceBinding(tenantId, id);
        if (result.success) _model.setSuccess("Binding deleted");
        else                _model.setError(result.errorMessage);
        _model.setBindings(_useCase.listServiceBindings(tenantId));
        return _view.buildListDescriptor(_model);
    }
}
