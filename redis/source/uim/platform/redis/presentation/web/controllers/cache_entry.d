/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.controllers.cache_entry;

import uim.platform.redis;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebCacheEntryController {
    private WebCacheEntryModel  _model;
    private WebCacheEntryView   _view;
    private ManageCacheEntriesUseCase _useCase;

    this(ManageCacheEntriesUseCase useCase) {
        _useCase = useCase;
        _model   = new WebCacheEntryModel();
        _view    = new WebCacheEntryView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/redis/cache-entries",    &handleList);
        router.get("/web/redis/cache-entries/*",  &handleDetail);
        router.post("/web/redis/cache-entries",   &handleCreate);
        router.post("/web/redis/cache-entries/*", &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        _model.setEntries(_useCase.listCacheEntries(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = CacheEntryId(extractIdFromPath(req.requestURI.to!string));
        auto e = _useCase.getCacheEntry(tenantId, id);
        _model.setSelected(e, !e.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        CacheEntryDTO dto;
        dto.tenantId   = tenantId;
        dto.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
        dto.key        = data.getString("key", "");
        dto.value      = data.getString("value", "");
        dto.entryType  = CacheEntryType.string_;
        dto.ttl        = data.getLong("ttl", -1);
        auto result = _useCase.createCacheEntry(dto);
        if (result.success) _model.setSuccess("Entry set: " ~ dto.key);
        else                _model.setError(400, result.message);
        _model.setEntries(_useCase.listCacheEntries(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = CacheEntryId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteCacheEntry(tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(400, result.message);
        _model.setEntries(_useCase.listCacheEntries(tenantId));
        _view.renderList(res, _model);
    }
}
