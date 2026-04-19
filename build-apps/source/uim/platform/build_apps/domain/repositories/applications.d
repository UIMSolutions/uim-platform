/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface ApplicationRepository {
    bool existsById(ApplicationId id);
    Application findById(ApplicationId id);

    Application[] findAll();
    Application[] findByTenant(TenantId tenantId);
    Application[] findByOwner(string owner);
    Application[] findByStatus(ApplicationStatus status);

    void save(Application entity);
    void update(Application entity);
    void remove(ApplicationId id);
}
