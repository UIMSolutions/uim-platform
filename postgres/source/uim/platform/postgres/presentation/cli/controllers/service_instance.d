/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.controllers.service_instance;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class CliServiceInstanceController {
    private CliServiceInstanceModel   _model;
    private CliServiceInstanceView    _view;
    private ManageServiceInstancesUseCase _useCase;

    this(ManageServiceInstancesUseCase useCase) {
        _useCase = useCase;
        _model   = new CliServiceInstanceModel();
        _view    = new CliServiceInstanceView();
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
        auto list = _useCase.listServiceInstances(tenantId);
        _model.setInstances(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = ServiceInstanceId(args[0]);
        auto inst = _useCase.getServiceInstance(tenantId, id);
        _model.setSelected(inst, !inst.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <name> <planId>"); return; }
        ServiceInstanceDTO dto;
        dto.tenantId    = tenantId;
        dto.name        = args[0];
        dto.planId      = ServicePlanId(args[1]);
        dto.memoryGb    = 4;
        dto.storageGb   = 20;
        dto.sslEnabled  = true;
        dto.hyperscaler = Hyperscaler.aws;
        auto result = _useCase.createServiceInstance(dto);
        if (result.success) _view.renderSuccess("Created instance: " ~ result.id);
        else                _view.renderError(result.message);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteServiceInstance(tenantId, ServiceInstanceId(args[0]));
        if (result.success) _view.renderSuccess("Deleted instance: " ~ args[0]);
        else                _view.renderError(result.message);
    }
}
