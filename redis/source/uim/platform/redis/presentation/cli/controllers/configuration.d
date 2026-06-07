/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.controllers.configuration;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class CliConfigurationController {
    private CliConfigurationModel  _model;
    private CliConfigurationView   _view;
    private ManageConfigurationsUseCase _useCase;

    this(ManageConfigurationsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliConfigurationModel();
        _view    = new CliConfigurationView();
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

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 1) { _view.renderError("Usage: create <instanceId>"); return; }
        ConfigurationDTO dto;
        dto.tenantId         = tenantId;
        dto.instanceId       = ServiceInstanceId(args[0]);
        dto.maxMemoryPolicy  = MaxMemoryPolicy.allkeys_lru;
        dto.persistenceMode  = PersistenceMode.none;
        auto result = _useCase.createConfiguration(dto);
        if (result.success) _view.renderSuccess("Created configuration: " ~ result.id);
        else                _view.renderError(result.message);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteConfiguration(tenantId, ConfigurationId(args[0]));
        if (result.success) _view.renderSuccess("Deleted configuration: " ~ args[0]);
        else                _view.renderError(result.message);
    }
}
