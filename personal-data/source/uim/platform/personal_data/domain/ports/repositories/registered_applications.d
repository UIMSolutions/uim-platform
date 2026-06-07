/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.registered_applications;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

interface RegisteredApplicationRepository : ITenantRepository!(RegisteredApplication, RegisteredApplicationId) {

    bool existsByName(TenantId tenantId, string name);
    RegisteredApplication findByName(TenantId tenantId, string name);
    void removeByName(TenantId tenantId, string name);

    size_t countByStatus(TenantId tenantId, ApplicationStatus status);
    RegisteredApplication[] findByStatus(TenantId tenantId, ApplicationStatus status);
    void removeByStatus(TenantId tenantId, ApplicationStatus status);

}
