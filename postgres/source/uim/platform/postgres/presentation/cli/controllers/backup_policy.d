/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.controllers.backup_policy;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class CliBackupPolicyController {
    private CliBackupPolicyModel   _model;
    private CliBackupPolicyView    _view;
    private ManageBackupPoliciesUseCase _useCase;

    this(ManageBackupPoliciesUseCase useCase) {
        _useCase = useCase;
        _model   = new CliBackupPolicyModel();
        _view    = new CliBackupPolicyView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":   handleList(tenantId, args[1..$]);   break;
            case "get":    handleGet(tenantId, args[1..$]);    break;
            case "create": handleCreate(tenantId, args[1..$]); break;
            case "delete": handleDelete(tenantId, args[1..$]); break;
            default:       _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listBackupPolicies(tenantId);
        _model.setPolicies(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto p = _useCase.getBackupPolicy(tenantId, BackupPolicyId(args[0]));
        _model.setSelected(p, !p.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 1) { _view.renderError("Usage: create <instanceId>"); return; }
        BackupPolicyDTO dto;
        dto.tenantId        = tenantId;
        dto.instanceId      = ServiceInstanceId(args[0]);
        dto.retentionPeriod = 7;
        dto.backupWindow    = "02:00-03:00";
        auto result = _useCase.createBackupPolicy(dto);
        if (result.success) _view.renderSuccess("Created backup policy: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteBackupPolicy(tenantId, BackupPolicyId(args[0]));
        if (result.success) _view.renderSuccess("Deleted backup policy: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
