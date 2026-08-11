/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.task_chains;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IManageTaskChainsUseCase { 
  
  CommandResult createTaskChain(CreateTaskChainRequest r);
  TaskChain getTaskChain(TenantId tenantId, SpaceId spaceId, TaskChainId id);
  TaskChain[] listTaskChains(TenantId tenantId, SpaceId spaceId);
  CommandResult patchTaskChain(PatchTaskChainRequest r);
  CommandResult deleteTaskChain(TenantId tenantId, SpaceId spaceId, TaskChainId id);

}
