/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.cache_entry;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

struct CacheEntry {
    mixin TenantEntity!(CacheEntryId);

    ServiceInstanceId instanceId;
    string key;
    string value;
    CacheEntryType entryType;
    long ttl;           // seconds; -1 = no expiry
    long sizeBytes;
    long accessCount;
    long lastAccessedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id",             id.value)
            .set("tenantId",       tenantId.value)
            .set("instanceId",     instanceId.value)
            .set("key",            key)
            .set("value",          value)
            .set("entryType",      entryType.to!string)
            .set("ttl",            ttl)
            .set("sizeBytes",      sizeBytes)
            .set("accessCount",    accessCount)
            .set("lastAccessedAt", lastAccessedAt)
            .set("createdAt",      createdAt)
            .set("createdBy",      createdBy.value)
            .set("updatedBy",      updatedBy.value);
    }
}
