/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.resource_groups;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManageResourceGroupsUseCase { 

  CommandResult createResourceGroup(CreateResourceGroupRequest r);

  ResourceGroup getResourceGroup(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id);

  ResourceGroup[] listResourceGroups(TenantId tenantId, ConnectionId connectionId);

  ResourceGroup[] listResourceGroups(TenantId tenantId);

  CommandResult patchResourceGroup(PatchResourceGroupRequest r);

  CommandResult deleteResourceGroup(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id);
  
}
