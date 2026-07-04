/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.backup_policy;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiBackupPolicyController {
    private GuiBackupPolicyModel   _model;
    private GuiBackupPolicyView    _view;
    private ManageBackupPoliciesUseCase _useCase;

    this(ManageBackupPoliciesUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiBackupPolicyModel();
        _view    = new GuiBackupPolicyView();
    }

    Json listPolicies(TenantId tenantId) {
        _model.setPolicies(_useCase.listBackupPolicies(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getPolicy(TenantId tenantId, BackupPolicyId id) {
        auto p = _useCase.getBackupPolicy(tenantId, id);
        _model.setSelected(p, !p.isNull);
        return _view.buildDetailDescriptor(_model);
    }
}
