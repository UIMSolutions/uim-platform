/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.repositories.logic_flows;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryLogicFlowRepository : TenantRepository!(LogicFlow, LogicFlowId), LogicFlowRepository {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }

    LogicFlow[] filterByApplication(LogicFlow[] flows, ApplicationId applicationId) {
        return flows.filter!(e => e.applicationId == applicationId).array;
    }

    LogicFlow[] findByApplication(TenantId tenantId, ApplicationId applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }

    void removeByApplication(TenantId tenantId, ApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(e => remove(e));
    }

     size_t countByPage(TenantId tenantId, PageId pageId) {
        return findByPage(tenantId, pageId).length;
    }

    LogicFlow[] filterByPage(LogicFlow[] flows, PageId pageId) {
        return flows.filter!(e => e.pageId == pageId).array;
    }
    
    LogicFlow[] findByPage(TenantId tenantId, PageId pageId) {
        return filterByPage(findByTenant(tenantId), pageId);
    }

    void removeByPage(TenantId tenantId, PageId pageId) {
        findByPage(tenantId, pageId).each!(e => remove(e));
    }
}
