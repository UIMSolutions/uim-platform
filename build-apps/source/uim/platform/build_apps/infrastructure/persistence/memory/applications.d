/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.repositories.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryApplicationRepository : TenantRepository!(Application, ApplicationId), ApplicationRepository {

    size_t countByOwner(TenantId tenantId, string owner) {
        return findByOwner(tenantId, owner).length;
    }

    Application[] filterByOwner(Application[] applications, string owner) {
        return applications.filter!(e => e.owner == owner).array;
    }

    Application[] findByOwner(TenantId tenantId, string owner) {
        return findByTenant(tenantId).filter!(e => e.owner == owner).array;
    }

    void removeByOwner(TenantId tenantId, string owner) {
        findByOwner(tenantId, owner).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, ApplicationStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Application[] filterByStatus(Application[] applications, ApplicationStatus status) {
        return applications.filter!(e => e.status == status).array;
    }

    Application[] findByStatus(TenantId tenantId, ApplicationStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, ApplicationStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
