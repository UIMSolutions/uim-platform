/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.manage.logic_flows;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManageLogicFlowsUseCase { 
    
    LogicFlow getLogicFlow(TenantId tenantId, LogicFlowId id);
    LogicFlow[] listLogicFlows(TenantId tenantId);
    LogicFlow[] listLogicFlows(TenantId tenantId, ApplicationId applicationId);
    LogicFlow[] listByPage(TenantId tenantId, PageId pageId);
    CommandResult createLogicFlow(LogicFlowDTO dto);
    CommandResult updateLogicFlow(LogicFlowDTO dto);
    CommandResult deleteLogicFlow(TenantId tenantId, LogicFlowId id);
}
