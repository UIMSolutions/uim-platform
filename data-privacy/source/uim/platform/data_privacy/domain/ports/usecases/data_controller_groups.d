/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.data_controller_groups;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageDataControllerGroupsUseCase { 

  UsecaseResult createGroup(CreateDataControllerGroupRequest req);
  DataControllerGroup getGroup(TenantId tenantId, DataControllerGroupId id);
  DataControllerGroup[] listGroups(TenantId tenantId);
  UsecaseResult updateGroup(UpdateDataControllerGroupRequest req);
  UsecaseResult deleteGroup(TenantId tenantId, DataControllerGroupId groupId);
  
}

