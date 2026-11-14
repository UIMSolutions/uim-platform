/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.users;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: SCIM-like user management.
interface IManageUsersUseCase {
  IAUser[] listUsers(TenantId tenantId);
  IAUser[] listByStatus(TenantId tenantId, UserStatus status);
  IAUser[] listByGroup(TenantId tenantId, GroupId groupId);
  IAUser getUser(TenantId tenantId, UserId id);
  IAUser findUser(TenantId tenantId, string emailOrUserName);

  UsecaseResult createUser(UserDTO dto);
  UsecaseResult updateUser(UserDTO dto);
  /// Lifecycle change (pendingVerification → active ⇄ locked, → inactive).
  /// Unlocking resets the failed login counter; deactivating revokes sessions.
  UsecaseResult setUserStatus(TenantId tenantId, UserId id, UserStatus status, UserId by);
  UsecaseResult changePassword(ChangePasswordRequest request);
  /// Administrative password reset.
  UsecaseResult resetPassword(TenantId tenantId, UserId id, string newPassword, UserId by);
  /// Enroll a second factor; data contains "secret" and "provisioningUri".
  UsecaseResult enrollMfa(TenantId tenantId, UserId id, MfaType mfaType, UserId by);
  UsecaseResult disableMfa(TenantId tenantId, UserId id, UserId by);
  /// Delete the user, its group memberships, sessions and tokens.
  UsecaseResult deleteUser(TenantId tenantId, UserId id);
}
