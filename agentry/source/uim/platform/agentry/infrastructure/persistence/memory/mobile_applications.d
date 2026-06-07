/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.mobile_applications;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

class MemoryMobileApplicationRepository
    : TenantRepository!(MobileApplication, MobileApplicationId), MobileApplicationRepository {

    size_t countByStatus(TenantId tenantId, AppStatus status) {
        return findByStatus(tenantId, status).length;
    }

    MobileApplication[] findByStatus(TenantId tenantId, AppStatus status) {
        return findByTenant(tenantId).filter!(a => a.status == status).array;
    }

    void removeByStatus(TenantId tenantId, AppStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByPlatform(TenantId tenantId, AppPlatform platform) {
        return findByPlatform(tenantId, platform).length;
    }

    MobileApplication[] findByPlatform(TenantId tenantId, AppPlatform platform) {
        return findByTenant(tenantId).filter!(a => a.platform == platform).array;
    }
}
