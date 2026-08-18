/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.business_roles;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for business role management.
interface IManageBusinessRolesUseCase { 

  UsecaseResult createBusinessRole(CreateBusinessRoleRequest req);
  UsecaseResult updateBusinessRole(UpdateBusinessRoleRequest req);
  bool existsBusinessRole(TenantId tenantId, BusinessRoleId id);
  BusinessRole getBusinessRole(TenantId tenantId, BusinessRoleId id);
  BusinessRole[] listBusinessRoles(TenantId tenantId, SystemInstanceId systemId);
  UsecaseResult deleteBusinessRole(TenantId tenantId, BusinessRoleId id);

}
