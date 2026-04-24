/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.pages;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryPageRepository : TenantRepository!(Page, PageId), PageRepository {

    size_t countByApplication(ApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }
    Page[] findByApplication(ApplicationId applicationId) {
        return findAll().filter!(e => e.applicationId == applicationId).array;
    }
    void removeByApplication(ApplicationId applicationId) {
        findByApplication(applicationId).each!(e => remove(e));
    }

}
