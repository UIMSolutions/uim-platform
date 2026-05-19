/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.service_instance;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiServiceInstanceController {
    private GuiServiceInstanceModel   _model;
    private GuiServiceInstanceView    _view;
    private ManageServiceInstancesUseCase _useCase;

    this(ManageServiceInstancesUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiServiceInstanceModel();
        _view    = new GuiServiceInstanceView();
    }

    Json listInstances(TenantId tenantId) {
        _model.setInstances(_useCase.listServiceInstances(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getinstance(TenantId tenantId, ServiceInstanceId id) {
        auto inst = _useCase.getServiceInstance(tenantId, id);
        _model.setSelected(inst, !inst.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json createInstance(TenantId tenantId, ServiceInstanceDTO dto) {
        auto result = _useCase.createServiceInstance(dto);
        if (result.success) _model.setSuccess("Instance created: " ~ result.id);
        else                _model.setError(result.error);
        _model.setInstances(_useCase.listServiceInstances(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json deleteInstance(TenantId tenantId, ServiceInstanceId id) {
        auto result = _useCase.deleteServiceInstance(tenantId, id);
        if (result.success) _model.setSuccess("Instance deleted");
        else                _model.setError(result.error);
        _model.setInstances(_useCase.listServiceInstances(tenantId));
        return _view.buildListDescriptor(_model);
    }
}
