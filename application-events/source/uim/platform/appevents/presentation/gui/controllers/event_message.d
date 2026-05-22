/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.event_message;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_messages;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.gui.models.event_message;
import uim.platform.appevents.presentation.gui.views.event_message;

@safe:

class GuiEventMessageController {
    private GuiEventMessageModel        _model;
    private GuiEventMessageView         _view;
    private ManageEventMessagesUseCase  _useCase;

    this(ManageEventMessagesUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiEventMessageModel();
        _view    = new GuiEventMessageView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listEventMessages(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, EventMessageId id) {
        auto item = _useCase.getEventMessage(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, EventMessageDTO dto) {
        auto result = _useCase.publishMessage(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Published: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, EventMessageId id) {
        auto result = _useCase.deleteEventMessage(tenantId, id);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Deleted: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
