/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.resource_groups;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
interface IManageResourceGroupsUseCase { 
  
  CommandResult createResourceGroup(CreateResourceGroupRequest r);
  CommandResult patchResourceGroup(PatchResourceGroupRequest r);
  ResourceGroup getResourceGroup(TenantId tenantId, ResourceGroupId resourceGroupId);
  ResourceGroup[] listResourceGroups(TenantId tenantId);
  size_t count(TenantId tenantId);
  CommandResult deleteResourceGroup(TenantId tenantId, ResourceGroupId resourceGroupId);

}
