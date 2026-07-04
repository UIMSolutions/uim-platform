/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.controllers.cache_entry;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class CliCacheEntryController {
    private CliCacheEntryModel  _model;
    private CliCacheEntryView   _view;
    private ManageCacheEntriesUseCase _useCase;

    this(ManageCacheEntriesUseCase useCase) {
        _useCase = useCase;
        _model   = new CliCacheEntryModel();
        _view    = new CliCacheEntryView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length == 0) { handleList(tenantId, args); return; }
        switch (args[0]) {
            case "list":   handleList(tenantId, args[1..$]);   break;
            case "get":    handleGet(tenantId, args[1..$]);    break;
            case "set":    handleCreate(tenantId, args[1..$]); break;
            case "delete": handleDelete(tenantId, args[1..$]); break;
            default:       _view.renderError("Unknown subcommand: " ~ args[0]);
        }
    }

    void handleList(TenantId tenantId, string[] args) {
        auto list = _useCase.listCacheEntries(tenantId);
        _model.setEntries(list);
        _view.renderList(_model);
    }

    void handleGet(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: get <id>"); return; }
        auto e = _useCase.getCacheEntry(tenantId, CacheEntryId(args[0]));
        _model.setSelected(e, !e.isNull);
        if (_model.hasSelected) _view.renderDetail(_model.selected);
        else _view.renderError(_model.errorMessage);
    }

    void handleCreate(TenantId tenantId, string[] args) {
        if (args.length < 3) { _view.renderError("Usage: set <instanceId> <key> <value>"); return; }
        CacheEntryDTO dto;
        dto.tenantId   = tenantId;
        dto.instanceId = ServiceInstanceId(args[0]);
        dto.key        = args[1];
        dto.value      = args[2];
        dto.entryType  = CacheEntryType.string_;
        dto.ttl        = -1;
        auto result = _useCase.createCacheEntry(dto);
        if (result.success) _view.renderSuccess("Set key: " ~ args[1]);
        else                _view.renderError(result.message);
    }

    void handleDelete(TenantId tenantId, string[] args) {
        if (args.length == 0) { _view.renderError("Usage: delete <id>"); return; }
        auto result = _useCase.deleteCacheEntry(tenantId, CacheEntryId(args[0]));
        if (result.success) _view.renderSuccess("Deleted entry: " ~ args[0]);
        else                _view.renderError(result.message);
    }
}
