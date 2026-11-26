/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests and results of the built-in login and user administration.
module uim.platform.application_events.application.dtos.access;

import uim.platform.application_events;

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
  string password;
  string[] scopes;
  bool locked;
}

struct UpdateUserRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Patch!string displayName;
  Patch!string password;
  Patch!(string[]) scopes;
  Patch!bool locked;
}
