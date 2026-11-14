/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Request models of the directory management use cases. Enum values are
/// carried as their external string representation and parsed (and rejected if
/// unknown) by the use cases, so every adapter gets the same checks.
module uim.platform.identity_authentication.application.dtos.directory;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

struct UserDTO {
  UserId userId;
  TenantId tenantId;

  string userName;
  string email;
  string firstName;
  string lastName;
  /// Only used on create (initial password).
  string password;
  string status;
  string phoneNumber;
  string externalIdpId;
  UserId createdBy;
  UserId updatedBy;

  static UserDTO fromEntity(const IAUser e) {
    UserDTO d;
    d.userId = e.id;
    d.tenantId = e.tenantId;
    d.userName = e.userName;
    d.email = e.email;
    d.firstName = e.firstName;
    d.lastName = e.lastName;
    d.status = enumValue(e.status);
    d.phoneNumber = e.phoneNumber;
    d.externalIdpId = e.externalIdpId;
    return d;
  }
}

struct GroupDTO {
  GroupId groupId;
  TenantId tenantId;

  string name;
  string description;
  UserId createdBy;
  UserId updatedBy;

  static GroupDTO fromEntity(const IAGroup e) {
    GroupDTO d;
    d.groupId = e.id;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.description = e.description;
    return d;
  }
}

struct ApplicationDTO {
  ApplicationId applicationId;
  TenantId tenantId;

  string name;
  string description;
  string protocol;
  string[] redirectUris;
  string[] allowedScopes;
  string samlEntityId;
  string samlAcsUrl;
  string samlMetadataUrl;
  bool active = true;
  UserId createdBy;
  UserId updatedBy;

  static ApplicationDTO fromEntity(const Application e) {
    ApplicationDTO d;
    d.applicationId = e.id;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.description = e.description;
    d.protocol = enumValue(e.protocol);
    d.redirectUris = e.redirectUris.dup;
    d.allowedScopes = e.allowedScopes.dup;
    d.samlEntityId = e.samlEntityId;
    d.samlAcsUrl = e.samlAcsUrl;
    d.samlMetadataUrl = e.samlMetadataUrl;
    d.active = e.active;
    return d;
  }
}

struct PolicyDTO {
  PolicyId policyId;
  TenantId tenantId;

  string name;
  string description;
  PolicyRule[] rules;
  string[] applicationIds;
  bool active = true;
  UserId createdBy;
  UserId updatedBy;

  static PolicyDTO fromEntity(const AuthorizationPolicy e) {
    PolicyDTO d;
    d.policyId = e.id;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.description = e.description;
    d.rules = e.rules.dup;
    d.applicationIds = e.applicationIds.dup;
    d.active = e.active;
    return d;
  }
}

struct RiskRuleDTO {
  RiskRuleId ruleId;
  TenantId tenantId;

  string name;
  RiskCondition[] conditions;
  string riskLevel;
  string requiredMfa;
  bool denyAccess;
  bool active = true;
  UserId createdBy;
  UserId updatedBy;

  static RiskRuleDTO fromEntity(const RiskRule e) {
    RiskRuleDTO d;
    d.ruleId = e.id;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.conditions = e.conditions.dup;
    d.riskLevel = enumValue(e.riskLevel);
    d.requiredMfa = enumValue(e.requiredMfa);
    d.denyAccess = e.denyAccess;
    d.active = e.active;
    return d;
  }
}

struct IdpConfigDTO {
  IdpConfigId idpId;
  TenantId tenantId;

  string name;
  string idpType;
  string metadataUrl;
  string authorizationEndpoint;
  string tokenEndpoint;
  string userInfoEndpoint;
  string clientId;
  /// Write-only.
  string clientSecret;
  string[] domainHints;
  bool isDefault;
  bool active = true;
  UserId createdBy;
  UserId updatedBy;

  static IdpConfigDTO fromEntity(const IdpConfig e) {
    IdpConfigDTO d;
    d.idpId = e.id;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.idpType = enumValue(e.idpType);
    d.metadataUrl = e.metadataUrl;
    d.authorizationEndpoint = e.authorizationEndpoint;
    d.tokenEndpoint = e.tokenEndpoint;
    d.userInfoEndpoint = e.userInfoEndpoint;
    d.clientId = e.clientId;
    d.domainHints = e.domainHints.dup;
    d.isDefault = e.isDefault;
    d.active = e.active;
    return d;
  }
}
