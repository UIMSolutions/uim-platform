/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.event_channel;

// import uim.platform.service;
// import uim.platform.appevents.application.dto;
// import uim.platform.appevents.application.usecases.manage.event_channels;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.presentation.gui.models.event_channel;
// import uim.platform.appevents.presentation.gui.views.event_channel;

import uim.platform.appevents;

// mixin(ShowModule!());

@safe:


class GuiEventChannelController {
    private GuiEventChannelModel        _model;
    private GuiEventChannelView         _view;
    private ManageEventChannelsUseCase  _useCase;

    this(ManageEventChannelsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiEventChannelModel();
        _view    = new GuiEventChannelView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listEventChannels(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, EventChannelId id) {
        auto item = _useCase.getEventChannel(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, EventChannelDTO dto) {
        auto result = _useCase.createEventChannel(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Created: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json update(TenantId tenantId, EventChannelDTO dto) {
        auto result = _useCase.updateEventChannel(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Updated: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, EventChannelId id) {
        auto result = _useCase.deleteEventChannel(tenantId, id);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Deleted: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
