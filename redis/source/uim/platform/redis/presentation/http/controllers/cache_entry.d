/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.cache_entry;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class CacheEntryController : ManageHttpController {
    private ManageCacheEntriesUseCase cacheEntries;

    this(ManageCacheEntriesUseCase cacheEntries) {
        this.cacheEntries = cacheEntries;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/cache-entries", &handleList);
        router.get("/api/v1/redis/cache-entries/*", &handleGet);
        router.post("/api/v1/redis/cache-entries", &handleCreate);
        router.put("/api/v1/redis/cache-entries/*", &handleUpdate);
        router.delete_("/api/v1/redis/cache-entries/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = cacheEntries.listCacheEntries(tenantId).map!(e => e.toJson()).array.toJson;
        return successResponse("Cache entries retrieved successfully", "Retrieved", 200, Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson()).array.toJson));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CacheEntryId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid cache entry ID").set("statusCode", 400);

        auto e = cacheEntries.getCacheEntry(tenantId, id);
        if (e.isNull)
            return errorResponse("Cache entry not found", 404);

        return successResponse("Cache entry retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CacheEntryDTO dto;
        dto.cacheEntryId = CacheEntryId(data.getString("cacheEntryId", ""));
        dto.tenantId = tenantId;
        dto.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
        dto.key = data.getString("key", "");
        dto.value = data.getString("value", "");
        dto.ttl = data.getLong("ttl", -1);
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = cacheEntries.createCacheEntry(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Cache entry created successfully", "Created", 201, Json.emptyObject
                .set("id", result.id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CacheEntryDTO dto;
        dto.cacheEntryId = CacheEntryId(precheck.id);
        dto.tenantId = tenantId;
        dto.value = data.getString("value", "");
        dto.ttl = data.getLong("ttl", -1);
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = cacheEntries.updateCacheEntry(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Cache entry updated successfully", "Updated", 200, Json.emptyObject
                .set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CacheEntryId(precheck.id);

        auto result = cacheEntries.deleteCacheEntry(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Cache entry deleted successfully", "Deleted", 200, Json.emptyObject
                .set("id", result.id));
    }
}
