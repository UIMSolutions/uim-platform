/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.logic_flows;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface LogicFlowRepository : ITenantRepository!(LogicFlow, LogicFlowId) {

    size_t countByApplication(ApplicationId applicationId);
    LogicFlow[] findByApplication(ApplicationId applicationId);
    void removeByApplication(ApplicationId applicationId);

    size_t countByPage(PageId pageId);
    LogicFlow[] findByPage(PageId pageId);
    void removeByPage(PageId pageId);

}
