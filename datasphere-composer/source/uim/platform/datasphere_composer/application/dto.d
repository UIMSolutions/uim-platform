/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.dto;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:

// ---- DataProvider DTOs ----

struct CreateDataProviderRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string systemType;
  string connectionUrl;
  string region;
  string[string] metadata;
}

struct UpdateDataProviderRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string status;
  string connectionUrl;
  string region;
}

// ---- DataProduct DTOs ----

struct CreateDataProductRequest {
  TenantId tenantId;
  string id;
  string providerId;
  string name;
  string description;
  string schemaVersion;
  string namespace;
  bool   enabled;
  string[string] metadata;
}

struct UpdateDataProductRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string status;
  bool   enabled;
}

// ---- UnificationRule DTOs ----

struct CreateUnificationRuleRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  int      priority;
  string   model;
  string[] identifierAttributes;
  bool     unique_;
  bool     triggerMerge;
  bool     preventMerge;
}

struct UpdateUnificationRuleRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  int      priority;
  string   model;
  string[] identifierAttributes;
  bool     unique_;
  bool     triggerMerge;
  bool     preventMerge;
  bool     active;
}

struct ReorderRulesRequest {
  string   tenantId;
  string[] orderedRuleIds;
}

// ---- DataSourceConfig DTOs ----

struct CreateDataSourceConfigRequest {
  TenantId tenantId;
  string id;
  string dataProductId;
  string providerId;
  string qualityRank;
  string timestampFormat;
  string timestampField;
  string timestampCustomPattern;
  bool   enabled;
  string[] disabledRuleIds;
}

struct UpdateDataSourceConfigRequest {
  TenantId tenantId;
  string id;
  string qualityRank;
  string timestampFormat;
  string timestampField;
  string timestampCustomPattern;
  bool   enabled;
  string[] disabledRuleIds;
}

struct AddIdentifierMappingRequest {
  TenantId tenantId;
  string configId;
  string ruleId;
  string ruleAttributeName;
  string sourceAttributeName;
  string transformationType;
}

// ---- AttributeMapping DTOs ----

struct CreateAttributeMappingRequest {
  string   tenantId;
  string   id;
  string   configId;
  string   sourceAttributeName;
  string   sourceDataType;
  string   targetAttributeName;
  string   targetDataType;
  string   delimiter;
  int      sortOrder;
}

struct UpdateAttributeMappingRequest {
  string   tenantId;
  string   id;
  string   sourceAttributeName;
  string   sourceDataType;
  string   targetAttributeName;
  string   targetDataType;
  string   delimiter;
  int      sortOrder;
  bool     active;
}

// ---- CustomerProfile DTOs (read-heavy) ----

struct SearchCustomerProfileRequest {
  TenantId tenantId;
  string email;
  string externalId;
  string fullName;
}

// ---- CompositionRun DTOs ----

struct StartCompositionRunRequest {
  string   tenantId;
  string   id;
  string   name;
  string[] dataProductIds;
  string   triggeredBy;
}

struct CompositionRunActionRequest {
  TenantId tenantId;
  string id;
  string action;  /// "cancel"
}

// ---- TenantUser DTOs ----

struct CreateTenantUserRequest {
  TenantId tenantId;
  string id;
  string email;
  string firstName;
  string lastName;
  string role;
  string externalUserId;
}

struct UpdateTenantUserRequest {
  TenantId tenantId;
  string id;
  string firstName;
  string lastName;
  string role;
  bool   active;
}
