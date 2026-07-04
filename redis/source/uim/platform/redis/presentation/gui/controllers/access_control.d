/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.access_control;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class GuiAccessControlController {
    private GuiAccessControlModel  _model;
    private GuiAccessControlView   _view;
    private ManageAccessControlsUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageAccessControlsUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase = useCase; _tenantId = tenantId;
        _model = new GuiAccessControlModel(); _view = new GuiAccessControlView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = tenantId; }
    GuiAccessControlModel model() { return _model; }

    Json loadList() {
        _model.setRules(_useCase.listAccessControls(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json loadDetail(AccessControlId id) {
        auto a = _useCase.getAccessControl(_tenantId, id);
        _model.setSelected(a, !a.isNull);
        return _view.buildDetailDescriptor(_model);
    }
    Json handleCreate(AccessControlDTO dto) {
        dto.tenantId = _tenantId;
        auto result = _useCase.createAccessControl(dto);
        if (result.success) _model.setSuccess("Created: " ~ result.id);
        else                _model.setError(result.message);
        _model.setRules(_useCase.listAccessControls(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json handleDelete(AccessControlId id) {
        auto result = _useCase.deleteAccessControl(_tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(result.message);
        _model.setRules(_useCase.listAccessControls(_tenantId));
        return _view.buildListDescriptor(_model);
    }
}
