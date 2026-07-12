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
struct AuthRequest {
  TenantId tenantId;
  ApplicationId applicationId;
  string email;
  string password;
  string mfaCode;
  string ipAddress;
  string userAgent;
}

struct AuthResult {
  bool success;
  string message;
  bool mfaRequired;
  MfaType mfaType = MfaType.none;
  string sessionId;
  UserId userId;
}
/// --- IAUser DTOs ---

struct CreateUserRequest {
  TenantId tenantId;
  string userName;
  string email;
  string firstName;
  string lastName;
  string password;
  string phoneNumber;
}

struct UpdateUserRequest {
  TenantId tenantId;

  UserId userId;
  string firstName;
  string lastName;
  string phoneNumber;
}

struct UserResponse {
  UserId userId;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}
/// --- IAGroup DTOs ---

struct CreateGroupRequest {
  TenantId tenantId;
  string name;
  string description;
}

struct GroupResponse {
  TenantId tenantId;
  GroupId groupId;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}
/// --- Application DTOs ---

struct CreateAppRequest {
  TenantId tenantId;
  ApplicationId applicationId;

  string name;
  string description;
  SsoProtocol protocol = SsoProtocol.oidc;
  string[] redirectUris;
  string[] allowedScopes;
  string samlEntityId;
  string samlAcsUrl;
}

struct UpdateAppRequest {
  TenantId tenantId;
  ApplicationId applicationId;
  string name;
  string[] redirectUris;
  string[] allowedScopes;
}

struct AppResponse {
  TenantId tenantId;

  string applicationId;
  string clientId;
  string clientSecret;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }
}
/// --- Tenant DTOs ---

struct CreateTenantRequest {
  string name;
  string subdomain;
  SsoProtocol defaultSsoProtocol = SsoProtocol.oidc;
  AuthMethod[] allowedAuthMethods;
  bool mfaEnforced;
}

struct UpdateTenantRequest {
  TenantId tenantId;
  string name;
  AuthMethod[] allowedAuthMethods;
}

struct TenantResponse {
  TenantId tenantId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }
}
/// --- Policy DTOs ---

struct CreatePolicyRequest {
  TenantId tenantId;
  string name;
  string description;
  PolicyRule[] rules;
  string[] applicationIds;
}

struct PolicyResponse {
  string policyId;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}

struct UpdatePolicyRequest {
  PolicyId policyId;
  string name;
  string description;
  PolicyRule[] rules;
  string[] applicationIds;
}

struct PolicyRuleResponse {
  string policyId;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}

struct ChangePasswordRequest {
  TenantId tenantId;
  UserId userId;
  string oldPassword;
  string newPassword;
}