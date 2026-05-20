/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.system_registration;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.system_registrations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.system_registration;
import uim.platform.appevents.presentation.web.views.system_registration;

@safe:

class WebSystemRegistrationController {
    private WebSystemRegistrationModel        _model;
    private WebSystemRegistrationView         _view;
    private ManageSystemRegistrationsUseCase  _useCase;

    this(ManageSystemRegistrationsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebSystemRegistrationModel();
        _view    = new WebSystemRegistrationView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listSystemRegistrations(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, SystemRegistrationId id) {
        auto item = _useCase.getSystemRegistration(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, SystemRegistrationDTO dto) {
        auto result = _useCase.registerSystem(dto);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("System registered: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, SystemRegistrationId id) {
        auto result = _useCase.unregisterSystem(tenantId, id);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("System unregistered: " ~ result.id);
    }
}
