/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.repositories.pages;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryPageRepository : TenantRepository!(Page, PageId), PageRepository {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }
    Page[] filterByApplication(Page[] pages, ApplicationId applicationId) {
        return pages.filter!(e => e.applicationId == applicationId).array;
    }

    Page[] findByApplication(TenantId tenantId, ApplicationId applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }
    
    void removeByApplication(TenantId tenantId, ApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(e => remove(e));
    }

}
