/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface ApplicationRepository : ITenantRepository!(Application, ApplicationId) {

    size_t countByOwner(string owner);
    Application[] findByOwner(string owner);
    void removeByOwner(string owner);

    size_t countByStatus(ApplicationStatus status);
    Application[] findByStatus(ApplicationStatus status);
    void removeByStatus(ApplicationStatus status);

}
