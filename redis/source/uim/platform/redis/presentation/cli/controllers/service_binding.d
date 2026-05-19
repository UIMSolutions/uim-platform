/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.controllers.service_binding;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class CliServiceBindingController {
    private CliServiceBindingModel  _model;
    private CliServiceBindingView   _view;
    private ManageServiceBindingsUseCase _useCase;

    this(ManageServiceBindingsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliServiceBindingModel();
        _view    = new CliServiceBindingView();
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
        auto list = _useCase.listServiceBindings(tenantId);
        _model.setBindings(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto b = _useCase.getServiceBinding(tenantId, ServiceBindingId(args[0]));
        _model.setSelected(b, !b.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <instanceId> <appId>"); return; }
        ServiceBindingDTO dto;
        dto.tenantId    = tenantId;
        dto.instanceId  = ServiceInstanceId(args[0]);
        dto.appId       = args[1];
        dto.name        = "binding-" ~ args[1];
        auto result = _useCase.createServiceBinding(dto);
        if (result.success) _view.renderSuccess("Created binding: " ~ result.id);
        else                _view.renderError(result.error);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteServiceBinding(tenantId, ServiceBindingId(args[0]));
        if (result.success) _view.renderSuccess("Deleted binding: " ~ args[0]);
        else                _view.renderError(result.error);
    }
}
