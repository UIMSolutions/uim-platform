/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.repositories.content_caches;

// import uim.platform.html_repository.domain.ports.repositories.content_caches;
// import uim.platform.html_repository.domain.entities.content_cache;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class ContentCacheMemoryRepository : TenantRepository!(ContentCache, ContentCacheId), IContentCacheRepository {

  bool existsByFile(TenantId tenantId, AppFileId fileId) {
    foreach (e; findByTenant(tenantId)) {
      if (e.fileId == fileId) return true;
    }
    return false;
  }
  ContentCache findByFile(TenantId tenantId, AppFileId fileId) {
    foreach (e; findByTenant(tenantId))
      if (e.fileId == fileId) return e;
    
    return ContentCache.init;
  }

  size_t countByStatus(TenantId tenantId, CacheStatus status) {
    return findByStatus(tenantId, status).length;
  }
  ContentCache[] filterByStatus(ContentCache[] caches, CacheStatus status) {
    return caches.filter!(c => c.status == status).array;
  }
  ContentCache[] findByStatus(TenantId tenantId, CacheStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  void removeByStatus(TenantId tenantId, CacheStatus status) {
    findByStatus(tenantId, status).each!(c => remove(c.id));
  }

  size_t countByExpiration(TenantId tenantId, long currentTime) {
    return findExpired(tenantId, currentTime).length;
  }
  ContentCache[] filterByExpiration(ContentCache[] caches, long currentTime) {
    return caches.filter!(c => c.expiresAt < currentTime).array;
  }
  ContentCache[] findExpired(TenantId tenantId, long currentTime) {
    return filterByExpiration(findByTenant(tenantId), currentTime);
  }
  void removeByExpiration(TenantId tenantId, long currentTime) {
    findExpired(tenantId, currentTime).each!(c => remove(c.id));
  }

  long totalSizeByTenant(TenantId tenantId) {
    return findByTenant(tenantId)
      .filter!(e => e.tenantId == tenantId)
      .map!(e => e.sizeBytes).sum;
  }
}
