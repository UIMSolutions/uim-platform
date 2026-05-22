/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.event_topic;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_topics;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.event_topic;
import uim.platform.appevents.presentation.web.views.event_topic;

@safe:

class WebEventTopicController {
    private WebEventTopicModel       _model;
    private WebEventTopicView        _view;
    private ManageEventTopicsUseCase _useCase;

    this(ManageEventTopicsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebEventTopicModel();
        _view    = new WebEventTopicView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listEventTopics(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, EventTopicId id) {
        auto item = _useCase.getEventTopic(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, EventTopicDTO dto) {
        auto result = _useCase.createEventTopic(dto);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Topic created: " ~ result.id)
            .set("id", result.id);
    }

    Json update(TenantId tenantId, EventTopicDTO dto) {
        auto result = _useCase.updateEventTopic(dto);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Topic updated: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, EventTopicId id) {
        auto result = _useCase.deleteEventTopic(tenantId, id);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Topic deleted: " ~ result.id);
    }
}
