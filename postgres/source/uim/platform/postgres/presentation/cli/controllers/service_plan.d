/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.controllers.service_plan;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class CliServicePlanController {
    private CliServicePlanModel   _model;
    private CliServicePlanView    _view;
    private ManageServicePlansUseCase _useCase;

    this(ManageServicePlansUseCase useCase) {
        _useCase = useCase;
        _model   = new CliServicePlanModel();
        _view    = new CliServicePlanView();
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
        auto list = _useCase.listServicePlans(tenantId);
        _model.setPlans(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto p = _useCase.getServicePlan(tenantId, ServicePlanId(args[0]));
        _model.setSelected(p, !p.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 1) { _view.renderError("Usage: create <name>"); return; }
        ServicePlanDTO dto;
        dto.tenantId   = tenantId;
        dto.name       = args[0];
        dto.memoryGb   = 4;
        dto.storageGb  = 20;
        dto.available  = true;
        auto result = _useCase.createServicePlan(dto);
        if (result.success) _view.renderSuccess("Created plan: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteServicePlan(tenantId, ServicePlanId(args[0]));
        if (result.success) _view.renderSuccess("Deleted plan: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
