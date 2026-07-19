/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.repositories.repositories;

import uim.platform.dms_integration;
mixin(ShowModule!());

@safe:

interface RepositoryRepository : ITenantRepository!(Repository_, RepositoryId) {

    size_t countByStatus(TenantId tenantId, RepositoryStatus status);
    Repository_[] findByStatus(TenantId tenantId, RepositoryStatus status);
    void removeByStatus(TenantId tenantId, RepositoryStatus status);

    size_t countByType(TenantId tenantId, RepositoryType repositoryType);
    Repository_[] findByType(TenantId tenantId, RepositoryType repositoryType);

    Repository_[] findDefault(TenantId tenantId);
}
