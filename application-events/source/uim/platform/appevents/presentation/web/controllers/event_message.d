/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.event_message;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_messages;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.event_message;
import uim.platform.appevents.presentation.web.views.event_message;

@safe:

class WebEventMessageController {
    private WebEventMessageModel        _model;
    private WebEventMessageView         _view;
    private ManageEventMessagesUseCase  _useCase;

    this(ManageEventMessagesUseCase useCase) {
        _useCase = useCase;
        _model   = new WebEventMessageModel();
        _view    = new WebEventMessageView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listEventMessages(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, EventMessageId id) {
        auto item = _useCase.getEventMessage(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, EventMessageDTO dto) {
        auto result = _useCase.publishMessage(dto);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Message published: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, EventMessageId id) {
        auto result = _useCase.deleteEventMessage(tenantId, id);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Message deleted: " ~ result.id);
    }
}
