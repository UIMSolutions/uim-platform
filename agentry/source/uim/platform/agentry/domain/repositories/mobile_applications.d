/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.repositories.mobile_applications;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

interface MobileApplicationRepository : ITenantRepository!(MobileApplication, MobileApplicationId) {
    size_t countByStatus(TenantId tenantId, AppStatus status);
    MobileApplication[] findByStatus(TenantId tenantId, AppStatus status);
    void removeByStatus(TenantId tenantId, AppStatus status);

    size_t countByPlatform(TenantId tenantId, AppPlatform platform);
    MobileApplication[] findByPlatform(TenantId tenantId, AppPlatform platform);
}
