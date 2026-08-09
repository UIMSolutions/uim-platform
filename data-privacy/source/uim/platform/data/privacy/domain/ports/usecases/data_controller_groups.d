/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.data_controller_groups;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageDataControllerGroupsUseCase { 

  CommandResult createGroup(CreateDataControllerGroupRequest req);
  DataControllerGroup getGroup(TenantId tenantId, DataControllerGroupId id);
  DataControllerGroup[] listGroups(TenantId tenantId);
  CommandResult updateGroup(UpdateDataControllerGroupRequest req);
  CommandResult deleteGroup(TenantId tenantId, DataControllerGroupId groupId);
  
}

