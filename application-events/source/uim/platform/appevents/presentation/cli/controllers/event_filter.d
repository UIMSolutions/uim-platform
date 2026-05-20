/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.controllers.event_filter;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_filters;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.cli.models.event_filter;
import uim.platform.appevents.presentation.cli.views.event_filter;

@safe:

class CliEventFilterController {
    private CliEventFilterModel        _model;
    private CliEventFilterView         _view;
    private ManageEventFiltersUseCase  _useCase;

    this(ManageEventFiltersUseCase useCase) {
        _useCase = useCase;
        _model   = new CliEventFilterModel();
        _view    = new CliEventFilterView();
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
        auto list = _useCase.listEventFilters(tenantId);
        _model.setItems(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = EventFilterId(args[0]);
        auto item = _useCase.getEventFilter(tenantId, id);
        _model.setSelected(item, !item.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <subscriptionId> <attribute>"); return; }
        EventFilterDTO dto;
        dto.tenantId       = tenantId;
        dto.subscriptionId = EventSubscriptionId(args[0]);
        dto.attribute      = args[1];
        auto result = _useCase.createEventFilter(dto);
        if (result.success) _view.renderSuccess("Created filter: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleUpdate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: update <id> <attribute>"); return; }
        EventFilterDTO dto;
        dto.filterId  = EventFilterId(args[0]);
        dto.tenantId  = tenantId;
        dto.attribute = args[1];
        auto result = _useCase.updateEventFilter(dto);
        if (result.success) _view.renderSuccess("Updated filter: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteEventFilter(tenantId, EventFilterId(args[0]));
        if (result.success) _view.renderSuccess("Deleted filter: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
