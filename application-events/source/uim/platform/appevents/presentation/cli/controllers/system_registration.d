/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.controllers.system_registration;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.system_registrations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.cli.models.system_registration;
import uim.platform.appevents.presentation.cli.views.system_registration;

@safe:

class CliSystemRegistrationController {
    private CliSystemRegistrationModel        _model;
    private CliSystemRegistrationView         _view;
    private ManageSystemRegistrationsUseCase  _useCase;

    this(ManageSystemRegistrationsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliSystemRegistrationModel();
        _view    = new CliSystemRegistrationView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":       handleList(tenantId, args[1..$]);       break;
            case "get":        handleGet(tenantId, args[1..$]);        break;
            case "register":   handleRegister(tenantId, args[1..$]);   break;
            case "unregister": handleUnregister(tenantId, args[1..$]); break;
            default:           _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listSystemRegistrations(tenantId);
        _model.setItems(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = SystemRegistrationId(args[0]);
        auto item = _useCase.getSystemRegistration(tenantId, id);
        _model.setSelected(item, !item.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleRegister(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: register <formationId> <systemId>"); return; }
        SystemRegistrationDTO dto;
        dto.tenantId    = tenantId;
        dto.formationId = FormationId(args[0]);
        dto.systemId    = args[1];
        auto result = _useCase.registerSystem(dto);
        if (result.success) _view.renderSuccess("Registered system: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleUnregister(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: unregister <id>"); return; }
        auto result = _useCase.unregisterSystem(tenantId, SystemRegistrationId(args[0]));
        if (result.success) _view.renderSuccess("Unregistered system: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
