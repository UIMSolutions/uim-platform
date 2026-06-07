/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.repositories.cache_entries;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

interface CacheEntryRepository : ITenantRepository!(CacheEntry, CacheEntryId) {
    CacheEntry[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId);
    CacheEntry   findByKey(TenantId tenantId, ServiceInstanceId instanceId, string key);
    CacheEntry[] findByType(TenantId tenantId, ServiceInstanceId instanceId, CacheEntryType entryType);
    bool         keyExists(TenantId tenantId, ServiceInstanceId instanceId, string key);
    long         countByInstance(TenantId tenantId, ServiceInstanceId instanceId);
}
