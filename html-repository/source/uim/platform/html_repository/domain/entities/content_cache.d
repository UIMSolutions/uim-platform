/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.entities.content_cache;

import uim.platform.html_repository.domain.types;

struct ContentCache {
  ContentCacheId id;
  TenantId tenantId;
  AppFileId fileId;
  string filePath;
  string contentType;
  string data;              // cached base64-encoded content
  string etag;
  CacheStatus status;
  long sizeBytes;
  long ttlSeconds;
  long cachedAt;
  long expiresAt;
  long lastAccessedAt;
  long hitCount;
}
