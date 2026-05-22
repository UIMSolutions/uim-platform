/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.formation;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.formations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.formation;
import uim.platform.appevents.presentation.web.views.formation;

@safe:

class WebFormationController {
    private WebFormationModel        _model;
    private WebFormationView         _view;
    private ManageFormationsUseCase  _useCase;

    this(ManageFormationsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebFormationModel();
        _view    = new WebFormationView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listFormations(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, FormationId id) {
        auto item = _useCase.getFormation(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, FormationDTO dto) {
        auto result = _useCase.createFormation(dto);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Formation created: " ~ result.id)
            .set("id", result.id);
    }

    Json update(TenantId tenantId, FormationDTO dto) {
        auto result = _useCase.updateFormation(dto);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Formation updated: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, FormationId id) {
        auto result = _useCase.deleteFormation(tenantId, id);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Formation deleted: " ~ result.id);
    }
}
