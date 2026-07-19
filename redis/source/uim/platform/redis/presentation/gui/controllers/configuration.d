/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.configuration;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class GuiConfigurationController {
    private GuiConfigurationModel  _model;
    private GuiConfigurationView   _view;
    private ManageConfigurationsUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageConfigurationsUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase = useCase; _tenantId = tenantId;
        _model = new GuiConfigurationModel(); _view = new GuiConfigurationView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = tenantId; }
    GuiConfigurationModel model() { return _model; }

    Json loadList() {
        _model.setConfigurations(_useCase.listConfigurations(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json loadDetail(ConfigurationId id) {
        auto c = _useCase.getConfiguration(_tenantId, id);
        _model.setSelected(c, !c.isNull);
        return _view.buildDetailDescriptor(_model);
    }
    Json handleCreate(ConfigurationDTO dto) {
        dto.tenantId = _tenantId;
        auto result = _useCase.createConfiguration(dto);
        if (result.success) _model.setSuccess("Created: " ~ result.id);
        else                _model.setError(result.message);
        _model.setConfigurations(_useCase.listConfigurations(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json handleDelete(ConfigurationId id) {
        auto result = _useCase.deleteConfiguration(_tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(result.message);
        _model.setConfigurations(_useCase.listConfigurations(_tenantId));
        return _view.buildListDescriptor(_model);
    }
}
