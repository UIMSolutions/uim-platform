/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.cache_entries;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter, any, count;
import std.array  : array;
import std.conv   : to;
mixin(ShowModule!());

@safe:

class FileCacheEntryRepository
    : TenantRepository!(CacheEntry, CacheEntryId)
    , CacheEntryRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "cache_entries.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        mkdirRecurse(path[0 .. path.lastIndexOf('/')]);
        Json arr = Json.emptyArray;
        foreach (i; findByTenant(tenantId)) arr ~= i.toJson();
        write(path, arr.toString());
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        if (!exists(path)) return;
        auto arr = parseJson(readText(path));
        if (!arr.isArray) return;
        foreach (j; arr.byValue()) {
            CacheEntry e;
            e.id          = CacheEntryId(data.getString("id", ""));
            e.tenantId    = tenantId;
            e.instanceId  = ServiceInstanceId(data.getString("instanceId", ""));
            e.key         = data.getString("key", "");
            e.value       = data.getString("value", "");
            e.entryType   = data.getString("entryType", "string").to!CacheEntryType;
            e.ttl         = data.getLong("ttl", -1);
            e.sizeBytes   = data.getLong("sizeBytes", 0);
            e.accessCount = data.getLong("accessCount", 0);
            e.lastAccessedAt = data.getLong("lastAccessedAt", 0);
            e.createdAt   = data.getLong("createdAt", 0);
            super.save(e);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(CacheEntry item)            { super.save(item); persistTenant(item.tenantId); }
    override void update(CacheEntry item)          { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, CacheEntryId id) { super.removeById(tenantId, id); persistTenant(tenantId); }

    override CacheEntry[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    override CacheEntry findByKey(TenantId tenantId, ServiceInstanceId instanceId, string key) {
        auto results = findByTenant(tenantId).filter!(e => e.instanceId == instanceId && e.key == key).array;
        return results.length > 0 ? results[0] : CacheEntry.init;
    }

    override CacheEntry[] findByType(TenantId tenantId, ServiceInstanceId instanceId, CacheEntryType entryType) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId && e.entryType == entryType).array;
    }

    override bool keyExists(TenantId tenantId, ServiceInstanceId instanceId, string key) {
        return findByTenant(tenantId).any!(e => e.instanceId == instanceId && e.key == key);
    }

    override long countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return cast(long) findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array.length;
    }
}
