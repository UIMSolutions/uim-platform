/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.executables;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface IManageExecutablesUseCase { 

    CommandResult createExecutable(CreateExecutableRequest r);
    Executable getExecutable(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutableId id);
    Executable[] listExecutables(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId);
    Executable[] listExecutables(TenantId tenantId, ResourceGroupId resourceGroupId);
    CommandResult deleteExecutable(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutableId id);

}
