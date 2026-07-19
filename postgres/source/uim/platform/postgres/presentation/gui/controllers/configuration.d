/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.controllers.configuration;

import uim.platform.postgres;
mixin(ShowModule!());

@safe:

class GuiConfigurationController {
    private GuiConfigurationModel   _model;
    private GuiConfigurationView    _view;
    private ManageConfigurationsUseCase _useCase;

    this(ManageConfigurationsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiConfigurationModel();
        _view    = new GuiConfigurationView();
    }

    Json listConfigurations(TenantId tenantId) {
        _model.setConfigurations(_useCase.listConfigurations(tenantId));
        return _view.buildListDescriptor(_model);
    }

    Json getConfiguration(TenantId tenantId, ConfigurationId id) {
        auto c = _useCase.getConfiguration(tenantId, id);
        _model.setSelected(c, !c.isNull);
        return _view.buildDetailDescriptor(_model);
    }
}
