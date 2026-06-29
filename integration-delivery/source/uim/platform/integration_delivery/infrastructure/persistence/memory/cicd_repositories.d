/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.memory.cicd_repositories;

import uim.platform.integration_delivery;
import std.algorithm : filter;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryCicdRepositoryRepository : TenantRepository!(CicdRepository, CicdRepositoryId), CicdRepositoryRepository {
    CicdRepository[] findByStatus(TenantId tenantId, RepositoryStatus status) {
        return findByTenant(tenantId).filter!(r => r.status == status).array;
    }

    CicdRepository[] findByType(TenantId tenantId, RepositoryType type) {
        return findByTenant(tenantId).filter!(r => r.repositoryType == type).array;
    }

    CicdRepository findByUrl(TenantId tenantId, string url) {
        auto results = findByTenant(tenantId).filter!(r => r.url == url).array;
        return results.length > 0 ? results[0] : CicdRepository.init;
    }
}
