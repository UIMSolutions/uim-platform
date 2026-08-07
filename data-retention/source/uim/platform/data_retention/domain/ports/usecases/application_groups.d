/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.application_groups;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageApplicationGroupsUseCase { 
    
    CommandResult createApplicationGroup(CreateApplicationGroupRequest req);
    CommandResult updateApplicationGroup(UpdateApplicationGroupRequest req);
    bool hasApplicationGroup(TenantId tenantId, ApplicationGroupId id);
    ApplicationGroup getApplicationGroup(TenantId tenantId, ApplicationGroupId id);
    ApplicationGroup[] listApplicationGroups(TenantId tenantId);
    CommandResult deleteApplicationGroup(TenantId tenantId, ApplicationGroupId id);

}
