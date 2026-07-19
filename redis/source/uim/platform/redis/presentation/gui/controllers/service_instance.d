/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.service_instance;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

/// GUI Controller for ServiceInstance.
/// Bridges GUI events (button clicks, form submits) to use cases and updates the model.
class GuiServiceInstanceController {
    private GuiServiceInstanceModel  _model;
    private GuiServiceInstanceView   _view;
    private ManageServiceInstancesUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageServiceInstancesUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase  = useCase;
        _tenantId = tenantId;
        _model    = new GuiServiceInstanceModel();
        _view     = new GuiServiceInstanceView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = tenantId; }

    GuiServiceInstanceModel model() { return _model; }

    /// Load all instances into the model.
    Json loadList() {
        auto list = _useCase.listServiceInstances(_tenantId);
        _model.setInstances(list);
        return _view.buildListDescriptor(_model);
    }

    /// Load a single instance.
    Json loadDetail(ServiceInstanceId id) {
        auto inst = _useCase.getServiceInstance(_tenantId, id);
        _model.setSelected(inst, !inst.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    /// Handle a create-form submission.
    Json handleCreate(ServiceInstanceDTO dto) {
        dto.tenantId = _tenantId;
        auto result = _useCase.createServiceInstance(dto);
        if (result.success) _model.setSuccess("Created: " ~ result.id);
        else                _model.setError(result.message);
        auto list = _useCase.listServiceInstances(_tenantId);
        _model.setInstances(list);
        return _view.buildListDescriptor(_model);
    }

    /// Handle a delete request.
    Json handleDelete(ServiceInstanceId id) {
        auto result = _useCase.deleteServiceInstance(_tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(result.message);
        auto list = _useCase.listServiceInstances(_tenantId);
        _model.setInstances(list);
        return _view.buildListDescriptor(_model);
    }

    /// Return the create-form descriptor.
    Json createForm() { return _view.buildCreateFormDescriptor(); }
}
