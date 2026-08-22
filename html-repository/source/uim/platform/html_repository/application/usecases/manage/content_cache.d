/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.content_cache;

// import uim.platform.html_repository.domain.ports.repositories.content_caches;
// import uim.platform.html_repository.domain.entities.content_cache;
// import uim.platform.html_repository.domain.services.content_delivery_service;
// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

class ManageContentCacheUseCase {
    private IContentCacheRepository repo;

    this(IContentCacheRepository repo) {
        this.repo = repo;
    }

    UsecaseResult cacheContent(CacheContentRequest r) {
        auto entry = ContentCache(r.tenantId);
        entry.fileId = r.fileId;
        entry.filePath = r.filePath;
        entry.contentType = r.contentType;
        entry.sizeBytes = cast(long) r.content.length;
        entry.etag = ContentDeliveryService.generateEtag(r.content);
        entry.content = r.content;
        entry.ttlSeconds = r.ttlSeconds;
        entry.cachedAt = currentTimestamp();
        entry.expiresAt = entry.cachedAt + r.ttlSeconds * 10_000_000L;
        entry.status = CacheStatus.valid;

        repo.save(entry);
        return UsecaseResult(true, entry.id.value, "");
    }

    ContentCache getContent(TenantId tenantId, ContentCacheId id) {
        return repo.findById(tenantId, id);
    }

    ContentCache getContent(TenantId tenantId, AppFileId fileId) {
        foreach (entry; repo.findByTenant(tenantId)) {
            if (entry.fileId == fileId)
                return entry;
        }
        return ContentCache.init;
    }

    UsecaseResult invalidateContent(TenantId tenantId, ContentCacheId id) {
        auto entry = repo.findById(tenantId, id);
        if (!entry.isNull) {
            entry.status = CacheStatus.invalid;
            repo.update(entry);
        }
        return UsecaseResult(true, entry.id.value, "Content invalidated");
    }

    UsecaseResult purgeExpiredContent(TenantId tenantId) {
        repo.removeExpired(tenantId, currentTimestamp());
        return UsecaseResult(true, "", "Expired content purged");
    }

    ContentCache[] listContent(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    size_t countContent(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

}
