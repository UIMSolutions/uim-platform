/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.system_registration;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.system_registrations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.gui.models.system_registration;
import uim.platform.appevents.presentation.gui.views.system_registration;

@safe:

class GuiSystemRegistrationController {
    private GuiSystemRegistrationModel        _model;
    private GuiSystemRegistrationView         _view;
    private ManageSystemRegistrationsUseCase  _useCase;

    this(ManageSystemRegistrationsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiSystemRegistrationModel();
        _view    = new GuiSystemRegistrationView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listSystemRegistrations(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, SystemRegistrationId id) {
        auto item = _useCase.getSystemRegistration(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, SystemRegistrationDTO dto) {
        auto result = _useCase.registerSystem(dto);
        if (result.hasError) { _model.setError(result.errorMessage); return Json.emptyObject.set("error", result.errorMessage); }
        _model.setSuccess("Registered: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, SystemRegistrationId id) {
        auto result = _useCase.unregisterSystem(tenantId, id);
        if (result.hasError) { _model.setError(result.errorMessage); return Json.emptyObject.set("error", result.errorMessage); }
        _model.setSuccess("Unregistered: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
