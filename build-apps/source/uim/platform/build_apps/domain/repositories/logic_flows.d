/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.logic_flows;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface LogicFlowRepository {
    bool existsById(LogicFlowId id);
    LogicFlow findById(LogicFlowId id);

    LogicFlow[] findAll();
    LogicFlow[] findByTenant(TenantId tenantId);
    LogicFlow[] findByApplication(ApplicationId applicationId);
    LogicFlow[] findByPage(PageId pageId);

    void save(LogicFlow entity);
    void update(LogicFlow entity);
    void remove(LogicFlowId id);
}
