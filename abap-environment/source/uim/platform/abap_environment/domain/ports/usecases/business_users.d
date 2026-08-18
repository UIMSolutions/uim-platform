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

  UsecaseResult createBusinessUser(CreateBusinessUserRequest req);
  UsecaseResult updateBusinessUser(UpdateBusinessUserRequest req);
  BusinessUser getBusinessUser(TenantId tenantId, BusinessUserId id);
  BusinessUser[] listBusinessUsers(TenantId tenantId, SystemInstanceId systemId);
  UsecaseResult deleteBusinessUser(TenantId tenantId, BusinessUserId id);
  
}
