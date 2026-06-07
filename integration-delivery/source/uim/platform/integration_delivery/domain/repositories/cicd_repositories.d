/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.repositories.cicd_repositories;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

interface CicdRepositoryRepository : ITenantRepository!(CicdRepository, CicdRepositoryId) {
    CicdRepository[] findByStatus(TenantId tenantId, RepositoryStatus status);
    CicdRepository[] findByType(TenantId tenantId, RepositoryType repositoryType);
    CicdRepository findByUrl(TenantId tenantId, string url);
}
