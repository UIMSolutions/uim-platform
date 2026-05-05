/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.registered_applications;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface RegisteredApplicationRepository : ITenantRepository!(RegisteredApplication, RegisteredApplicationId) {

    bool existsByName(string name);
    RegisteredApplication findByName(string name);
    void removeByName(string name);

    size_t countByStatus(ApplicationStatus status);
    RegisteredApplication[] findByStatus(ApplicationStatus status, size_t offset = 0, size_t limit = 100);
    void removeByStatus(ApplicationStatus status);

}
