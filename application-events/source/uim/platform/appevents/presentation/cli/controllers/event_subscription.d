/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.controllers.event_subscription;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_subscriptions;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.cli.models.event_subscription;
import uim.platform.appevents.presentation.cli.views.event_subscription;

@safe:

class CliEventSubscriptionController {
    private CliEventSubscriptionModel        _model;
    private CliEventSubscriptionView         _view;
    private ManageEventSubscriptionsUseCase  _useCase;

    this(ManageEventSubscriptionsUseCase useCase) {
        _useCase = useCase;
        _model   = new CliEventSubscriptionModel();
        _view    = new CliEventSubscriptionView();
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
        auto list = _useCase.listEventSubscriptions(tenantId);
        _model.setItems(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = EventSubscriptionId(args[0]);
        auto item = _useCase.getEventSubscription(tenantId, id);
        _model.setSelected(item, !item.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <name> <eventType>"); return; }
        EventSubscriptionDTO dto;
        dto.tenantId  = tenantId;
        dto.name      = args[0];
        dto.eventType = args[1];
        auto result = _useCase.createEventSubscription(dto);
        if (result.success) _view.renderSuccess("Created subscription: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleUpdate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: update <id> <name>"); return; }
        EventSubscriptionDTO dto;
        dto.subscriptionId = EventSubscriptionId(args[0]);
        dto.tenantId       = tenantId;
        dto.name           = args[1];
        auto result = _useCase.updateEventSubscription(dto);
        if (result.success) _view.renderSuccess("Updated subscription: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteEventSubscription(tenantId, EventSubscriptionId(args[0]));
        if (result.success) _view.renderSuccess("Deleted subscription: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
