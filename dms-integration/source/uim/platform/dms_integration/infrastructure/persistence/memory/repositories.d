/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.persistence.repositories.repositories;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class MemoryRepositoryRepository : TenantRepository!(Repository_, RepositoryId), RepositoryRepository {

    size_t countByStatus(TenantId tenantId, RepositoryStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Repository_[] findByStatus(TenantId tenantId, RepositoryStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }
    void removeByStatus(TenantId tenantId, RepositoryStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByType(TenantId tenantId, RepositoryType repositoryType) {
        return findByType(tenantId, repositoryType).length;
    }
    Repository_[] findByType(TenantId tenantId, RepositoryType repositoryType) {
        return findByTenant(tenantId).filter!(e => e.repositoryType == repositoryType).array;
    }

    Repository_[] findDefault(TenantId tenantId) {
        return findByTenant(tenantId).filter!(e => e.isDefault).array;
    }
}
