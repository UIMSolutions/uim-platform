/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.database_user;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class GuiDatabaseUserController {
    private GuiDatabaseUserModel   _model;
    private GuiDatabaseUserView    _view;
    private ManageDatabaseUsersUseCase _useCase;

    this(ManageDatabaseUsersUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiDatabaseUserModel();
        _view    = new GuiDatabaseUserView();
    }

    Json listUsers(TenantId tenantId) {
        _model.setUsers(_useCase.listDatabaseUsers(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getUser(TenantId tenantId, DatabaseUserId id) {
        auto u = _useCase.getDatabaseUser(tenantId, id);
        _model.setSelected(u, !u.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json createUser(TenantId tenantId, DatabaseUserDTO dto) {
        auto result = _useCase.createDatabaseUser(dto);
        if (result.success) _model.setSuccess("User created: " ~ result.id);
        else                _model.setError(result.message);
        _model.setUsers(_useCase.listDatabaseUsers(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json deleteUser(TenantId tenantId, DatabaseUserId id) {
        auto result = _useCase.deleteDatabaseUser(tenantId, id);
        if (result.success) _model.setSuccess("User deleted");
        else                _model.setError(result.message);
        _model.setUsers(_useCase.listDatabaseUsers(tenantId));
        return _view.buildListDescriptor(_model);
    }
}
