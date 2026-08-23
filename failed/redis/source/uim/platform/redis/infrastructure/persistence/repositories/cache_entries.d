/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.repositories.cache_entries;

import uim.platform.redis;
import std.algorithm : filter, any, count;
import std.array : array;

mixin(ShowModule!());

@safe:

class CacheEntryRepository : TenantRepository!(CacheEntry, CacheEntryId), ICacheEntryRepository {
    CacheEntry[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    CacheEntry findByKey(TenantId tenantId, ServiceInstanceId instanceId, string key) {
        auto results = findByTenant(tenantId).filter!(e => e.instanceId == instanceId && e.key == key)
            .array;
        return results.length > 0 ? results[0] : CacheEntry.init;
    }

    CacheEntry[] findByType(TenantId tenantId, ServiceInstanceId instanceId, CacheEntryType entryType) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId && e.entryType == entryType)
            .array;
    }

    bool keyExists(TenantId tenantId, ServiceInstanceId instanceId, string key) {
        return findByTenant(tenantId).any!(e => e.instanceId == instanceId && e.key == key);
    }

    long countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array.length;
    }
}
