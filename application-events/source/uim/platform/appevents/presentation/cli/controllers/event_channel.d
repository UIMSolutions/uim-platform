/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.controllers.event_channel;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_channels;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.cli.models.event_channel;
import uim.platform.appevents.presentation.cli.views.event_channel;

@safe:

class CliEventChannelController {
    private CliEventChannelModel        _model;
    private CliEventChannelView         _view;
    private ManageEventChannelsUseCase  _useCase;

    this(ManageEventChannelsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliEventChannelModel();
        _view    = new CliEventChannelView();
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
        auto list = _useCase.listEventChannels(tenantId);
        _model.setItems(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = EventChannelId(args[0]);
        auto item = _useCase.getEventChannel(tenantId, id);
        _model.setSelected(item, !item.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <name> <topicId>"); return; }
        EventChannelDTO dto;
        dto.tenantId = precheck.tenantId;
        dto.name     = args[0];
        dto.topicId  = EventTopicId(args[1]);
        auto result = _useCase.createEventChannel(dto);
        if (result.success) _view.renderSuccess("Created channel: " ~ result.id);
        else                _view.renderError(result.message);
    }

    void handleUpdate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: update <id> <name>"); return; }
        EventChannelDTO dto;
        dto.channelId = EventChannelId(args[0]);
        dto.tenantId  = tenantId;
        dto.name      = args[1];
        auto result = _useCase.updateEventChannel(dto);
        if (result.success) _view.renderSuccess("Updated channel: " ~ result.id);
        else                _view.renderError(result.message);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteEventChannel(tenantId, EventChannelId(args[0]));
        if (result.success) _view.renderSuccess("Deleted channel: " ~ args[0]);
        else                _view.renderError(result.message);
    }
}
