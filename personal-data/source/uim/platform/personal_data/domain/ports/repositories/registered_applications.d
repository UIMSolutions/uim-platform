/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.registered_applications;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface RegisteredApplicationRepository {
    RegisteredApplication findById(RegisteredApplicationId id);
    RegisteredApplication[] findByTenant(TenantId tenantId);
    RegisteredApplication findByName(string name);
    RegisteredApplication[] findByStatus(ApplicationStatus status);
    void save(RegisteredApplication entity);
    void update(RegisteredApplication entity);
    void remove(RegisteredApplicationId id);
}
