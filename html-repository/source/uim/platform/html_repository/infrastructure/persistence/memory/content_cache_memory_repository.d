/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.content_cache_memory_repository;

import uim.platform.html_repository.domain.ports.content_cache_repository;
import uim.platform.html_repository.domain.entities.content_cache;
import uim.platform.html_repository.domain.types;

class ContentCacheMemoryRepository : ContentCacheRepository {
  private ContentCache[] store;

  ContentCache findById(ContentCacheId id) {
    foreach (e; store) {
      if (e.id == id) return e;
    }
    return ContentCache.init;
  }

  ContentCache findByFileId(AppFileId fileId) {
    foreach (e; store) {
      if (e.fileId == fileId) return e;
    }
    return ContentCache.init;
  }

  ContentCache[] findByTenant(TenantId tenantId) {
    ContentCache[] result;
    foreach (e; store) {
      if (e.tenantId == tenantId) result ~= e;
    }
    return result;
  }

  ContentCache[] findByStatus(CacheStatus status) {
    ContentCache[] result;
    foreach (e; store) {
      if (e.status == status) result ~= e;
    }
    return result;
  }

  ContentCache[] findExpired(long currentTime) {
    ContentCache[] result;
    foreach (e; store) {
      if (e.expiresAt < currentTime) result ~= e;
    }
    return result;
  }

  void save(ContentCache cache) {
    store ~= cache;
  }

  void update(ContentCache cache) {
    foreach (i, e; store) {
      if (e.id == cache.id) {
        store[i] = cache;
        return;
      }
    }
  }

  void remove(ContentCacheId id) {
    ContentCache[] result;
    foreach (e; store) {
      if (e.id != id) result ~= e;
    }
    store = result;
  }

  void removeExpired(long currentTime) {
    ContentCache[] result;
    foreach (e; store) {
      if (e.expiresAt >= currentTime) result ~= e;
    }
    store = result;
  }

  long countByTenant(TenantId tenantId) {
    long count = 0;
    foreach (e; store) {
      if (e.tenantId == tenantId) count++;
    }
    return count;
  }

  long totalSizeByTenant(TenantId tenantId) {
    long total = 0;
    foreach (e; store) {
      if (e.tenantId == tenantId) total += e.sizeBytes;
    }
    return total;
  }
}
