/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.cache_entries;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ManageCacheEntriesUseCase {
    private ICacheEntryRepository repo;

    this(ICacheEntryRepository repo) { this.repo = repo; }

    CacheEntry getCacheEntry(TenantId tenantId, CacheEntryId id) {
        return repo.findById(tenantId, id);
    }

    CacheEntry[] listCacheEntries(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CacheEntry[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CacheEntry[] listByType(TenantId tenantId, ServiceInstanceId instanceId, CacheEntryType entryType) {
        return repo.findByType(tenantId, instanceId, entryType);
    }

    UsecaseResult createCacheEntry(CacheEntryDTO dto) {
        if (repo.keyExists(dto.tenantId, dto.instanceId, dto.key))
            return UsecaseResult(false, "", "Cache key already exists in this instance");

        auto e = CacheEntry(dto.tenantId, dto.cacheEntryId, dto.createdBy);
        e.instanceId = dto.instanceId;
        e.key = dto.key;
        e.value = dto.value;
        e.entryType = dto.entryType;
        e.ttl = dto.ttl == 0 ? -1 : dto.ttl;

        if (!RedisValidator.isValidCacheEntry(e))
            return UsecaseResult(false, "", "Invalid cache entry: instanceId and key required");

        repo.save(e);
        return UsecaseResult(true, e.id.value, "");
    }

    UsecaseResult updateCacheEntry(CacheEntryDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.cacheEntryId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Cache entry not found");

        if (dto.value.length > 0) existing.value = dto.value;
        existing.ttl = dto.ttl == 0 ? -1 : dto.ttl;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteCacheEntry(TenantId tenantId, CacheEntryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Cache entry not found");
        repo.remove(tenantId, id);
        return UsecaseResult(true, id.value, "");
    }
}
