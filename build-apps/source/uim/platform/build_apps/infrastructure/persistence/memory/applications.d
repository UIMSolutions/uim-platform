/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryApplicationRepository : TenantRepository!(Application, ApplicationId), ApplicationRepository {

    size_t countByOwner(string owner) {
        return findByOwner(owner).length;
    }

    Application[] findByOwner(string owner) {
        return findAll().filter!(e => e.owner == owner).array;
    }

    void removeByOwner(string owner) {
        findByOwner(owner).each!(e => remove(e.id));
    }

    size_t countByStatus(ApplicationStatus status) {
        return findByStatus(status).length;
    }

    Application[] findByStatus(ApplicationStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(ApplicationStatus status) {
        findByStatus(status).each!(e => remove(e.id));
    }

}
