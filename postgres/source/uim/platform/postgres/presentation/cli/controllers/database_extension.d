/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.controllers.database_extension;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class CliDatabaseExtensionController {
    private CliDatabaseExtensionModel   _model;
    private CliDatabaseExtensionView    _view;
    private ManageDatabaseExtensionsUseCase _useCase;

    this(ManageDatabaseExtensionsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliDatabaseExtensionModel();
        _view    = new CliDatabaseExtensionView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":   handleList(tenantId, args[1..$]);   break;
            case "get":    handleGet(tenantId, args[1..$]);    break;
            case "enable": handleCreate(tenantId, args[1..$]); break;
            case "disable":handleDelete(tenantId, args[1..$]); break;
            default:       _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listDatabaseExtensions(tenantId);
        _model.setExtensions(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto e = _useCase.getDatabaseExtension(tenantId, DatabaseExtensionId(args[0]));
        _model.setSelected(e, !e.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: enable <instanceId> <extensionName>"); return; }
        DatabaseExtensionDTO dto;
        dto.tenantId       = tenantId;
        dto.instanceId     = ServiceInstanceId(args[0]);
        dto.extensionName  = args[1];
        dto.schema_        = "public";
        auto result = _useCase.createDatabaseExtension(dto);
        if (result.success) _view.renderSuccess("Enabled extension: " ~ result.id);
        else                _view.renderError(result.message);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: disable <id>"); return; }
        auto result = _useCase.deleteDatabaseExtension(tenantId, DatabaseExtensionId(args[0]));
        if (result.success) _view.renderSuccess("Disabled extension: " ~ args[0]);
        else                _view.renderError(result.message);
    }
}
