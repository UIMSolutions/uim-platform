/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.database_extension;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiDatabaseExtensionController {
    private GuiDatabaseExtensionModel   _model;
    private GuiDatabaseExtensionView    _view;
    private ManageDatabaseExtensionsUseCase _useCase;

    this(ManageDatabaseExtensionsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiDatabaseExtensionModel();
        _view    = new GuiDatabaseExtensionView();
    }

    Json listExtensions(TenantId tenantId) {
        _model.setExtensions(_useCase.listDatabaseExtensions(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getExtension(TenantId tenantId, DatabaseExtensionId id) {
        auto e = _useCase.getDatabaseExtension(tenantId, id);
        _model.setSelected(e, !e.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json createExtension(TenantId tenantId, DatabaseExtensionDTO dto) {
        auto result = _useCase.createDatabaseExtension(dto);
        if (result.success) _model.setSuccess("Extension enabled: " ~ result.id);
        else                _model.setError(result.error);
        _model.setExtensions(_useCase.listDatabaseExtensions(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json deleteExtension(TenantId tenantId, DatabaseExtensionId id) {
        auto result = _useCase.deleteDatabaseExtension(tenantId, id);
        if (result.success) _model.setSuccess("Extension disabled");
        else                _model.setError(result.error);
        _model.setExtensions(_useCase.listDatabaseExtensions(tenantId));
        return _view.buildListDescriptor(_model);
    }
}
