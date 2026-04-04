/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.content_caches;

import uim.platform.html_repository.domain.entities.content_cache;
import uim.platform.html_repository.domain.types;

interface ContentCacheRepository {
  ContentCache findById(ContentCacheId id);
  ContentCache findByFileId(AppFileId fileId);
  ContentCache[] findByTenant(TenantId tenantId);
  ContentCache[] findByStatus(CacheStatus status);
  ContentCache[] findExpired(long currentTime);
  void save(ContentCache cache);
  void update(ContentCache cache);
  void remove(ContentCacheId id);
  void removeExpired(long currentTime);
  long countByTenant(TenantId tenantId);
  long totalSizeByTenant(TenantId tenantId);
}
