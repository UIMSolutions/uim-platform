/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.event_topic;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_topics;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.gui.models.event_topic;
import uim.platform.appevents.presentation.gui.views.event_topic;

@safe:

class GuiEventTopicController {
    private GuiEventTopicModel       _model;
    private GuiEventTopicView        _view;
    private ManageEventTopicsUseCase _useCase;

    this(ManageEventTopicsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiEventTopicModel();
        _view    = new GuiEventTopicView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listEventTopics(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, EventTopicId id) {
        auto item = _useCase.getEventTopic(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, EventTopicDTO dto) {
        auto result = _useCase.createEventTopic(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Created: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json update(TenantId tenantId, EventTopicDTO dto) {
        auto result = _useCase.updateEventTopic(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Updated: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, EventTopicId id) {
        auto result = _useCase.deleteEventTopic(tenantId, id);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Deleted: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
