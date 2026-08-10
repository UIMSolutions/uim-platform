/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.content_caches;
// import uim.platform.html_repository.domain.entities.content_cache;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface IContentCacheRepository : ITenantRepository!(ContentCache, ContentCacheId) {

  size_t countByStatus(TenantId tenantId, CacheStatus status);
  ContentCache[] findByStatus(TenantId tenantId, CacheStatus status);
  void removeByStatus(TenantId tenantId, CacheStatus status);
  
  size_t countExpired(TenantId tenantId, long currentTime);
  ContentCache[] findExpired(TenantId tenantId, long currentTime);
  void removeExpired(TenantId tenantId, long currentTime);
  
  long totalSizeByTenant(TenantId tenantId);
}
