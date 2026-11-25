/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the built-in login and user administration.
module uim.platform.job_scheduling.ports.usecases.access;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IAuthenticate {
  /// Check the credentials and issue an access token (throws unauthorized).
  LoginResult login(LoginRequest r);
  /// Change the own password (the current one must be given).
  void changePassword(ChangePasswordRequest r);
}

interface IManageUsers {
  UserAccount createUser(CreateUserRequest r);
  UserAccount updateUser(UpdateUserRequest r);
  UserAccount getUser(TenantId t, UserAccountId id);
  UserAccount[] listUsers(TenantId t);
  /// Refused for the own account and for the last administrator.
  void deleteUser(TenantId t, UserAccountId id, UserId actor);
  /// Create the administrator if the tenant has no users; returns true if created.
  bool ensureAdministrator(TenantId t, string name, string password);
  /// Issue a token without password (trusted local adapters: CLI).
  IssuedToken issueToken(TenantId t, UserAccountId id);
}
