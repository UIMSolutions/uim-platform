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
  DataProviderId id;
  string name;
  string description;
  string systemType;
  string connectionUrl;
  string region;
  string[string] metadata;
}

struct UpdateDataProviderRequest {
  TenantId tenantId;
  DataProviderId id;
  string name;
  string description;
  string status;
  string connectionUrl;
  string region;
}

// ---- DataProduct DTOs ----

struct CreateDataProductRequest {
  TenantId tenantId;
  DataProductId productId;
  DataProviderId providerId;
  string name;
  string description;
  string schemaVersion;
  string namespace;
  bool   enabled;
  string[string] metadata;
}

struct UpdateDataProductRequest {
  TenantId tenantId;
  DataProductId productId;
  string name;
  string description;
  string status;
  bool   enabled;
}

// ---- UnificationRule DTOs ----

struct CreateUnificationRuleRequest {
  TenantId tenantId;
  UnificationRuleId ruleId;
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
  TenantId tenantId;
  UnificationRuleId ruleId;
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
  TenantId tenantId;
  UnificationRuleId[] orderedRuleIds;
}

// ---- DataSourceConfig DTOs ----

struct CreateDataSourceConfigRequest {
  TenantId tenantId;
  DataSourceConfigId configId;
  DataProductId dataProductId;
  DataProviderId providerId;
  string qualityRank;
  string timestampFormat;
  string timestampField;
  string timestampCustomPattern;
  bool   enabled;
  string[] disabledRuleIds;
}

struct UpdateDataSourceConfigRequest {
  TenantId tenantId;
  DataSourceConfigId configId;
  string qualityRank;
  string timestampFormat;
  string timestampField;
  string timestampCustomPattern;
  bool   enabled;
  string[] disabledRuleIds;
}

struct AddIdentifierMappingRequest {
  TenantId tenantId;
  DataSourceConfigId configId;
  string ruleId;
  string ruleAttributeName;
  string sourceAttributeName;
  string transformationType;
}

// ---- AttributeMapping DTOs ----

struct CreateAttributeMappingRequest {
  TenantId tenantId;
  AttributeMappingId mappingId;
  DataSourceConfigId configId;
  string   sourceAttributeName;
  string   sourceDataType;
  string   targetAttributeName;
  string   targetDataType;
  string   delimiter;
  int      sortOrder;
}

struct UpdateAttributeMappingRequest {
  TenantId tenantId;
  AttributeMappingId mappingId;
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
  TenantId tenantId;
  CompositionRunId runId;
  string   name;
  string[] dataProductIds;
  string   triggeredBy;
}

struct CompositionRunActionRequest {
  TenantId tenantId;
  CompositionRunId runId;
  string action;  /// "cancel"
}

// ---- TenantUser DTOs ----

struct CreateTenantUserRequest {
  TenantId tenantId;
  TenantUserId userId;
  string email;
  string firstName;
  string lastName;
  string role;
  string externalUserId;
}

struct UpdateTenantUserRequest {
  TenantId tenantId;
  TenantUserId userId;
  string firstName;
  string lastName;
  string role;
  bool   active;
}
