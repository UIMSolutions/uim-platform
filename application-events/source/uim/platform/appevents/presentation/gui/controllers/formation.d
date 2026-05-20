/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.formation;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.formations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.gui.models.formation;
import uim.platform.appevents.presentation.gui.views.formation;

@safe:

class GuiFormationController {
    private GuiFormationModel        _model;
    private GuiFormationView         _view;
    private ManageFormationsUseCase  _useCase;

    this(ManageFormationsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiFormationModel();
        _view    = new GuiFormationView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listFormations(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, FormationId id) {
        auto item = _useCase.getFormation(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, FormationDTO dto) {
        auto result = _useCase.createFormation(dto);
        if (result.hasError) { _model.setError(result.errorMessage); return Json.emptyObject.set("error", result.errorMessage); }
        _model.setSuccess("Created: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json update(TenantId tenantId, FormationDTO dto) {
        auto result = _useCase.updateFormation(dto);
        if (result.hasError) { _model.setError(result.errorMessage); return Json.emptyObject.set("error", result.errorMessage); }
        _model.setSuccess("Updated: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, FormationId id) {
        auto result = _useCase.deleteFormation(tenantId, id);
        if (result.hasError) { _model.setError(result.errorMessage); return Json.emptyObject.set("error", result.errorMessage); }
        _model.setSuccess("Deleted: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
