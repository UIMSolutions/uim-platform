/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.controllers.database_user;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class CliDatabaseUserController {
    private CliDatabaseUserModel   _model;
    private CliDatabaseUserView    _view;
    private ManageDatabaseUsersUseCase _useCase;

    this(ManageDatabaseUsersUseCase useCase) {
        _useCase = useCase;
        _model   = new CliDatabaseUserModel();
        _view    = new CliDatabaseUserView();
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
        auto list = _useCase.listDatabaseUsers(tenantId);
        _model.setUsers(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto u = _useCase.getDatabaseUser(tenantId, DatabaseUserId(args[0]));
        _model.setSelected(u, !u.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <instanceId> <username>"); return; }
        DatabaseUserDTO dto;
        dto.tenantId   = tenantId;
        dto.instanceId = ServiceInstanceId(args[0]);
        dto.username   = args[1];
        dto.roles      = "readonly";
        auto result = _useCase.createDatabaseUser(dto);
        if (result.success) _view.renderSuccess("Created database user: " ~ result.id);
        else                _view.renderError(result.message);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteDatabaseUser(tenantId, DatabaseUserId(args[0]));
        if (result.success) _view.renderSuccess("Deleted database user: " ~ args[0]);
        else                _view.renderError(result.message);
    }
}
