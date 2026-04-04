/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage_content_cache;

import uim.platform.html_repository.domain.ports.content_cache_repository;
import uim.platform.html_repository.domain.entities.content_cache;
import uim.platform.html_repository.domain.services.content_delivery_service;
import uim.platform.html_repository.domain.types;
import uim.platform.html_repository.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageContentCacheUseCase : UIMUseCase {
    private ContentCacheRepository repo;

    this(ContentCacheRepository repo) {
        this.repo = repo;
    }

    CommandResult cache(CacheContentRequest r) {
        ContentCache entry;
        entry.id = randomUUID().to!string;
        entry.tenantId = r.tenantId;
        entry.appId = r.appId;
        entry.fileId = r.fileId;
        entry.filePath = r.filePath;
        entry.contentType = r.contentType;
        entry.sizeBytes = r.sizeBytes;
        entry.etag = ContentDeliveryService.generateEtag(r.content);
        entry.content = r.content;
        entry.ttlSeconds = r.ttlSeconds;
        entry.cachedAt = currentTimestamp();
        entry.expiresAt = entry.cachedAt + r.ttlSeconds * 10_000_000L;
        entry.status = CacheStatus.active;

        repo.save(entry);
        return CommandResult(true, entry.id, "");
    }

    ContentCache get_(ContentCacheId id) {
        return repo.findById(id);
    }

    ContentCache getByFileId(AppFileId fileId) {
        return repo.findByFileId(fileId);
    }

    void invalidate(ContentCacheId id) {
        auto entry = repo.findById(id);
        if (entry.id.length > 0) {
            entry.status = CacheStatus.invalidated;
            repo.update(entry);
        }
    }

    void purgeExpired() {
        repo.purgeExpired(currentTimestamp());
    }

    ContentCache[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    long countByTenant(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
