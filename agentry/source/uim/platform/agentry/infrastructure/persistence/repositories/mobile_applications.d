/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.repositories.mobile_applications;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MobileApplicationRepository
    : TenantRepository!(MobileApplication, MobileApplicationId), IMobileApplicationRepository {
    mixin TenantRepositoryTemplate!(MobileApplicationRepository, MobileApplication, MobileApplicationId);

    size_t countByStatus(TenantId tenantId, AppStatus status) {
        return findByStatus(tenantId, status).length;
    }

    MobileApplication[] filterByStatus(MobileApplication[] apps, AppStatus status) {
        return apps.filter!(a => a.status == status).array;
    }

    MobileApplication[] findByStatus(TenantId tenantId, AppStatus status) {
        return filterByStatus(find(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, AppStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByPlatform(TenantId tenantId, AppPlatform platform) {
        return findByPlatform(tenantId, platform).length;
    }

    MobileApplication[] filterByPlatform(MobileApplication[] apps, AppPlatform platform) {
        return apps.filter!(a => a.platform == platform).array;
    }

    MobileApplication[] findByPlatform(TenantId tenantId, AppPlatform platform) {
        return filterByPlatform(find(tenantId), platform);
    }
    void removeByPlatform(TenantId tenantId, AppPlatform platform) {
        findByPlatform(tenantId, platform).each!(e => remove(e));
    }
}
///
unittest {  
    assert(tenantRepositoryTest(new MobileApplicationRepository));
}