/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.controllers.event_topic;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_topics;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.cli.models.event_topic;
import uim.platform.appevents.presentation.cli.views.event_topic;

@safe:

class CliEventTopicController {
    private CliEventTopicModel        _model;
    private CliEventTopicView         _view;
    private ManageEventTopicsUseCase  _useCase;

    this(ManageEventTopicsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliEventTopicModel();
        _view    = new CliEventTopicView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":   handleList(tenantId, args[1..$]);   break;
            case "get":    handleGet(tenantId, args[1..$]);    break;
            case "create": handleCreate(tenantId, args[1..$]); break;
            case "update": handleUpdate(tenantId, args[1..$]); break;
            case "delete": handleDelete(tenantId, args[1..$]); break;
            default:       _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listEventTopics(tenantId);
        _model.setItems(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = EventTopicId(args[0]);
        auto item = _useCase.getEventTopic(tenantId, id);
        _model.setSelected(item, !item.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <name> <namespace>"); return; }
        EventTopicDTO dto;
        dto.tenantId  = tenantId;
        dto.name      = args[0];
        dto.namespace = args[1];
        dto.version_  = args.length >= 3 ? args[2] : "1.0.0";
        auto result = _useCase.createEventTopic(dto);
        if (result.success) _view.renderSuccess("Created topic: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleUpdate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: update <id> <name>"); return; }
        EventTopicDTO dto;
        dto.topicId  = EventTopicId(args[0]);
        dto.tenantId = tenantId;
        dto.name     = args[1];
        auto result = _useCase.updateEventTopic(dto);
        if (result.success) _view.renderSuccess("Updated topic: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteEventTopic(tenantId, EventTopicId(args[0]));
        if (result.success) _view.renderSuccess("Deleted topic: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
