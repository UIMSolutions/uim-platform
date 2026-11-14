/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.business_users;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Business users: maintain, lock/unlock, reset password, (un)assign roles.
/// Roles are given by id or name of a business role of the same system.
interface IManageBusinessUsersUseCase : IManageResource!(BusinessUser, BusinessUserId,
    CreateBusinessUserRequest, UpdateBusinessUserRequest) {
  UsecaseResult lock(TenantId tenantId, BusinessUserId id, UserId actor);
  UsecaseResult unlock(TenantId tenantId, BusinessUserId id, UserId actor);
  UsecaseResult resetPassword(TenantId tenantId, BusinessUserId id, UserId actor);
  UsecaseResult assignRole(TenantId tenantId, BusinessUserId id, string role, UserId actor);
  UsecaseResult unassignRole(TenantId tenantId, BusinessUserId id, string role, UserId actor);
}
