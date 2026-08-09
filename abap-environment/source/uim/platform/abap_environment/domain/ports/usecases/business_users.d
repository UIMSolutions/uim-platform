/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.business_users;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for business user management.
interface IManageBusinessUsersUseCase { 

  CommandResult createBusinessUser(CreateBusinessUserRequest req);
  CommandResult updateBusinessUser(UpdateBusinessUserRequest req);
  BusinessUser getBusinessUser(TenantId tenantId, BusinessUserId id);
  BusinessUser[] listBusinessUsers(TenantId tenantId, SystemInstanceId systemId);
  CommandResult deleteBusinessUser(TenantId tenantId, BusinessUserId id);
  
}
