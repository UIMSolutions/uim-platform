/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.service_binding;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class GuiServiceBindingController {
    private GuiServiceBindingModel  _model;
    private GuiServiceBindingView   _view;
    private ManageServiceBindingsUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageServiceBindingsUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase = useCase; _tenantId = tenantId;
        _model = new GuiServiceBindingModel(); _view = new GuiServiceBindingView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = tenantId; }
    GuiServiceBindingModel model() { return _model; }

    Json loadList() {
        _model.setBindings(_useCase.listServiceBindings(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json loadDetail(ServiceBindingId id) {
        auto b = _useCase.getServiceBinding(_tenantId, id);
        _model.setSelected(b, !b.isNull);
        return _view.buildDetailDescriptor(_model);
    }
    Json handleCreate(ServiceBindingDTO dto) {
        dto.tenantId = _tenantId;
        auto result = _useCase.createServiceBinding(dto);
        if (result.success) _model.setSuccess("Created: " ~ result.id);
        else                _model.setError(result.message);
        _model.setBindings(_useCase.listServiceBindings(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json handleDelete(ServiceBindingId id) {
        auto result = _useCase.deleteServiceBinding(_tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(result.message);
        _model.setBindings(_useCase.listServiceBindings(_tenantId));
        return _view.buildListDescriptor(_model);
    }
}
