/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.content_cache_repository;

import uim.platform.html_repository.domain.ports.repositories.content_caches;
import uim.platform.html_repository.domain.entities.content_cache;
import uim.platform.html_repository.domain.types;

class ContentCacheMemoryRepository : TenantRepository!(ContentCache, ContentCacheId), ContentCacheRepository {

  bool existsByFileId(AppFileId fileId) {
    foreach (e; findAll) {
      if (e.fileId == fileId) return true;
    }
    return false;
  }
  ContentCache findByFileId(AppFileId fileId) {
    foreach (e; findAll) {
      if (e.fileId == fileId) return e;
    }
    return ContentCache.init;
  }

  size_t countByStatus(CacheStatus status) {
    return findByStatus(status).length;
  }
  ContentCache[] filterByStatus(ContentCache[] caches, CacheStatus status) {
    return caches.filter!(c => c.status == status).array;
  }
  ContentCache[] findByStatus(CacheStatus status) {
    return filterByStatus(findAll(), status);
  }
  void removeByStatus(CacheStatus status) {
    findByStatus(status).each!(c => remove(c.id));
  }

  size_t countByExpiration(long currentTime) {
    return findExpired(currentTime).length;
  }
  ContentCache[] filterByExpiration(ContentCache[] caches, long currentTime) {
    return caches.filter!(c => c.expiresAt < currentTime).array;
  }
  ContentCache[] findExpired(long currentTime) {
    return filterByExpiration(findAll(), currentTime);
  }
  void removeByExpiration(long currentTime) {
    findExpired(currentTime).each!(c => remove(c.id));
  }

  long totalSizeByTenant(TenantId tenantId) {
    long total = 0;
    foreach (e; findAll) {
      if (e.tenantId == tenantId) total += e.sizeBytes;
    }
    return total;
  }
}
