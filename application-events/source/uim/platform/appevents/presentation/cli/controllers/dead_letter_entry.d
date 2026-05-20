/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.controllers.dead_letter_entry;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.dead_letter_entries;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.cli.models.dead_letter_entry;
import uim.platform.appevents.presentation.cli.views.dead_letter_entry;

@safe:

class CliDeadLetterEntryController {
    private CliDeadLetterEntryModel        _model;
    private CliDeadLetterEntryView         _view;
    private ManageDeadLetterEntriesUseCase _useCase;

    this(ManageDeadLetterEntriesUseCase useCase) {
        _useCase = useCase;
        _model   = new CliDeadLetterEntryModel();
        _view    = new CliDeadLetterEntryView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":   handleList(tenantId, args[1..$]);   break;
            case "get":    handleGet(tenantId, args[1..$]);    break;
            case "create": handleCreate(tenantId, args[1..$]); break;
            case "delete": handleDelete(tenantId, args[1..$]); break;
            default:       _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listDeadLetterEntries(tenantId);
        _model.setItems(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto id   = DeadLetterEntryId(args[0]);
        auto item = _useCase.getDeadLetterEntry(tenantId, id);
        _model.setSelected(item, !item.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 2) { _view.renderError("Usage: create <channelId> <errorMessage>"); return; }
        DeadLetterEntryDTO dto;
        dto.tenantId     = tenantId;
        dto.channelId    = EventChannelId(args[0]);
        dto.errorMessage = args[1];
        auto result = _useCase.createDeadLetterEntry(dto);
        if (result.success) _view.renderSuccess("Created dead letter entry: " ~ result.id);
        else                _view.renderError(result.errorMessage);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteDeadLetterEntry(tenantId, DeadLetterEntryId(args[0]));
        if (result.success) _view.renderSuccess("Deleted dead letter entry: " ~ args[0]);
        else                _view.renderError(result.errorMessage);
    }
}
