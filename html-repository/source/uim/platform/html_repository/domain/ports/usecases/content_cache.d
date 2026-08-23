/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.content_cache;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

interface IManageContentCacheUseCase {

    UsecaseResult cacheContent(CacheContentRequest r);

    ContentCache getContent(TenantId tenantId, ContentCacheId id);

    ContentCache getContent(TenantId tenantId, AppFileId fileId);

    UsecaseResult invalidateContent(TenantId tenantId, ContentCacheId id);

    UsecaseResult purgeExpiredContent(TenantId tenantId);

    ContentCache[] listContent(TenantId tenantId);

    size_t countContent(TenantId tenantId);

}
