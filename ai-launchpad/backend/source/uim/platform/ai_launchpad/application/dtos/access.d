/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests and results of the built-in login and the user administration.
module uim.platform.ai_launchpad.application.dtos.access;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct LoginRequest {
  TenantId tenantId;
  string username;
  string password;
}

struct LoginResult {
  IssuedToken token;
  UserAccount user;
  string[] scopes;
}

struct ChangePasswordRequest {
  TenantId tenantId;
  UserId actor; /// the user changing the own password
  string currentPassword;
  string newPassword;
}

struct CreateUserRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  string displayName;
  string email;
  string password;
  string[] roles;
  bool locked;
}

struct UpdateUserRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Patch!string displayName;
  Patch!string email;
  Patch!string password;
  Patch!(string[]) roles;
  Patch!bool locked;
}
