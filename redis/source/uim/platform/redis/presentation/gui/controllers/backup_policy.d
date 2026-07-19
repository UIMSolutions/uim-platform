/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.backup_policy;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class GuiBackupPolicyController {
    private GuiBackupPolicyModel  _model;
    private GuiBackupPolicyView   _view;
    private ManageBackupPoliciesUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageBackupPoliciesUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase = useCase; _tenantId = tenantId;
        _model = new GuiBackupPolicyModel(); _view = new GuiBackupPolicyView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = tenantId; }
    GuiBackupPolicyModel model() { return _model; }

    Json loadList() {
        _model.setPolicies(_useCase.listBackupPolicies(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json loadDetail(BackupPolicyId id) {
        auto p = _useCase.getBackupPolicy(_tenantId, id);
        _model.setSelected(p, !p.isNull);
        return _view.buildDetailDescriptor(_model);
    }
    Json handleCreate(BackupPolicyDTO dto) {
        dto.tenantId = _tenantId;
        auto result = _useCase.createBackupPolicy(dto);
        if (result.success) _model.setSuccess("Created: " ~ result.id);
        else                _model.setError(result.message);
        _model.setPolicies(_useCase.listBackupPolicies(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json handleDelete(BackupPolicyId id) {
        auto result = _useCase.deleteBackupPolicy(_tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(result.message);
        _model.setPolicies(_useCase.listBackupPolicies(_tenantId));
        return _view.buildListDescriptor(_model);
    }
}
