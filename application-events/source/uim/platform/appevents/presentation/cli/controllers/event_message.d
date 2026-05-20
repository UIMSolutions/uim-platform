/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.controllers.event_message;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_messages;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.cli.models.event_message;
import uim.platform.appevents.presentation.cli.views.event_message;

@safe:

class CliEventMessageController {
    private CliEventMessageModel        _model;
    private CliEventMessageView         _view;
    private ManageEventMessagesUseCase  _useCase;

    this(ManageEventMessagesUseCase useCase) {
        _useCase = useCase;
        _model   = new CliEventMessageModel();
        _view    = new CliEventMessageView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":    handleList(tenantId, args[1..$]);    break;
            case "get":     handleGet(tenantId, args[1..$]);     break;
            case "publish": handlePublish(tenantId, args[1..$]); break;
            case "delete":  handleDelete(tenantId, args[1..$]);  break;
            default:        _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listEventMessages(tenantId);
        _model.setItems(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = EventMessageId(args[0]);
        auto item = _useCase.getEventMessage(tenantId, id);
        _model.setSelected(item, !item.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handlePublish(TenantId tenantId, string[] args) {
        if (args.length < 3) { _view.renderError("Usage: publish <channelId> <eventType> <payload>"); return; }
        EventMessageDTO dto;
        dto.tenantId  = tenantId;
        dto.channelId = EventChannelId(args[0]);
        dto.eventType = args[1];
        dto.payload   = args[2];
        auto result = _useCase.publishMessage(dto);
        if (result.success) _view.renderSuccess("Published message: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteEventMessage(tenantId, EventMessageId(args[0]));
        if (result.success) _view.renderSuccess("Deleted message: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
