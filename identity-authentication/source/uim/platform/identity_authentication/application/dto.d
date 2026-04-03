/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.dto;

// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.entities.policy : PolicyRule;

/// --- Authentication DTOs ---
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
struct AuthRequest
{
  TenantId tenantId;
  ApplicationId applicationId;
  string email;
  string password;
  string mfaCode;
  string ipAddress;
  string userAgent;
}

struct AuthResult
{
  bool success;
  string message;
  bool mfaRequired;
  MfaType mfaType = MfaType.none;
  string sessionId;
  string userId;
}

/// --- User DTOs ---

struct CreateUserRequest
{
  TenantId tenantId;
  string userName;
  string email;
  string firstName;
  string lastName;
  string password;
  string phoneNumber;
}

struct UpdateUserRequest
{
  UserId userId;
  string firstName;
  string lastName;
  string phoneNumber;
}

struct UserResponse
{
  string userId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- IdaGroup DTOs ---

struct CreateGroupRequest
{
  TenantId tenantId;
  string name;
  string description;
}

struct GroupResponse
{
  string groupId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- Application DTOs ---

struct CreateAppRequest
{
  TenantId tenantId;
  string name;
  string description;
  SsoProtocol protocol = SsoProtocol.oidc;
  string[] redirectUris;
  string[] allowedScopes;
  string samlEntityId;
  string samlAcsUrl;
}

struct UpdateAppRequest
{
  ApplicationId applicationId;
  string name;
  string[] redirectUris;
  string[] allowedScopes;
}

struct AppResponse
{
  string applicationId;
  string clientId;
  string clientSecret;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- Tenant DTOs ---

struct CreateTenantRequest
{
  string name;
  string subdomain;
  SsoProtocol defaultSsoProtocol = SsoProtocol.oidc;
  AuthMethod[] allowedAuthMethods;
  bool mfaEnforced;
}

struct UpdateTenantRequest
{
  TenantId tenantId;
  string name;
  AuthMethod[] allowedAuthMethods;
}

struct TenantResponse
{
  string tenantId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- Policy DTOs ---

struct CreatePolicyRequest
{
  TenantId tenantId;
  string name;
  string description;
  PolicyRule[] rules;
  string[] applicationIds;
}

struct PolicyResponse
{
  string policyId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}
