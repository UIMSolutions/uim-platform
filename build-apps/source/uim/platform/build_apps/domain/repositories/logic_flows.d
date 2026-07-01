/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.logic_flows;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

interface LogicFlowRepository : ITenantRepository!(LogicFlow, LogicFlowId) {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId);
    LogicFlow[] findByApplication(TenantId tenantId, ApplicationId applicationId);
    void removeByApplication(TenantId tenantId, ApplicationId applicationId);

    size_t countByPage(TenantId tenantId, PageId pageId);
    LogicFlow[] findByPage(TenantId tenantId, PageId pageId);
    void removeByPage(TenantId tenantId, PageId pageId);

}
