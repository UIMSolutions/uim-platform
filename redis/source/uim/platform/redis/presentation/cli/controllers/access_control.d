/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.controllers.access_control;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class CliAccessControlController {
    private CliAccessControlModel  _model;
    private CliAccessControlView   _view;
    private ManageAccessControlsUseCase _useCase;

    this(ManageAccessControlsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliAccessControlModel();
        _view    = new CliAccessControlView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":   handleList(tenantId, args[1..$]);   break;
            case "get":    handleGet(tenantId, args[1..$]);    break;
            case "add":    handleCreate(tenantId, args[1..$]); break;
            case "delete": handleDelete(tenantId, args[1..$]); break;
            default:       _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listAccessControls(tenantId);
        _model.setRules(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto a = _useCase.getAccessControl(tenantId, AccessControlId(args[0]));
        _model.setSelected(a, !a.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 3) { _view.renderError("Usage: add <instanceId> <cidr> <allow|deny>"); return; }
        AccessControlDTO dto;
        dto.tenantId   = tenantId;
        dto.instanceId = ServiceInstanceId(args[0]);
        dto.cidrBlock  = args[1];
        dto.action     = args[2];
        dto.direction  = "inbound";
        dto.priority   = 100;
        auto result = _useCase.createAccessControl(dto);
        if (result.success) _view.renderSuccess("Added access rule: " ~ result.id);
        else                _view.renderError(result.error);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteAccessControl(tenantId, AccessControlId(args[0]));
        if (result.success) _view.renderSuccess("Deleted access rule: " ~ args[0]);
        else                _view.renderError(result.error);
    }
}
