/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.business_roles;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Business roles. A role assigned to users cannot be deleted.
interface IManageBusinessRolesUseCase : IManageResource!(BusinessRole, BusinessRoleId,
    CreateBusinessRoleRequest, UpdateBusinessRoleRequest) {
  UsecaseResult addCatalog(TenantId tenantId, BusinessRoleId id, string catalog, UserId actor);
  UsecaseResult removeCatalog(TenantId tenantId, BusinessRoleId id, string catalog, UserId actor);
  /// Number of users that have the role.
  size_t userCount(TenantId tenantId, BusinessRoleId id);
}
