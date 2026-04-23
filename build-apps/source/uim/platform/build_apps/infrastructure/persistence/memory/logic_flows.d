/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.logic_flows;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryLogicFlowRepository : TenantRepository!(LogicFlow, LogicFlowId), LogicFlowRepository {

    size_t countByApplication(ApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }

    LogicFlow[] findByApplication(ApplicationId applicationId) {
        return findByTenant(tenantId).filter!(e => e.applicationId == applicationId).array;
    }

    void removeByApplication(ApplicationId applicationId) {
        findByApplication(applicationId).each!(e => remove(e));
    }

     size_t countByPage(PageId pageId) {
        return findByPage(pageId).length;
    }

    LogicFlow[] findByPage(PageId pageId) {
        return findByTenant(tenantId).filter!(e => e.pageId == pageId).array;
    }

    void removeByPage(PageId pageId) {
        findByPage(pageId).each!(e => remove(e));
    }
}
