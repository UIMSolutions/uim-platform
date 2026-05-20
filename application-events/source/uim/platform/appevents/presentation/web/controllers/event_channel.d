/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.event_channel;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_channels;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.event_channel;
import uim.platform.appevents.presentation.web.views.event_channel;

@safe:

class WebEventChannelController {
    private WebEventChannelModel        _model;
    private WebEventChannelView         _view;
    private ManageEventChannelsUseCase  _useCase;

    this(ManageEventChannelsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebEventChannelModel();
        _view    = new WebEventChannelView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listEventChannels(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, EventChannelId id) {
        auto item = _useCase.getEventChannel(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, EventChannelDTO dto) {
        auto result = _useCase.createEventChannel(dto);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Channel created: " ~ result.id)
            .set("id", result.id);
    }

    Json update(TenantId tenantId, EventChannelDTO dto) {
        auto result = _useCase.updateEventChannel(dto);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Channel updated: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, EventChannelId id) {
        auto result = _useCase.deleteEventChannel(tenantId, id);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Channel deleted: " ~ result.id);
    }
}
