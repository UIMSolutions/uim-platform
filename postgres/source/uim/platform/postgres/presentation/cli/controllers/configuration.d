/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.controllers.configuration;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class CliConfigurationController {
    private CliConfigurationModel   _model;
    private CliConfigurationView    _view;
    private ManageConfigurationsUseCase _useCase;

    this(ManageConfigurationsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliConfigurationModel();
        _view    = new CliConfigurationView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list": handleList(tenantId, args[1..$]); break;
            case "get":  handleGet(tenantId, args[1..$]);  break;
            default:     _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listConfigurations(tenantId);
        _model.setConfigurations(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto c = _useCase.getConfiguration(tenantId, ConfigurationId(args[0]));
        _model.setSelected(c, !c.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }
}
