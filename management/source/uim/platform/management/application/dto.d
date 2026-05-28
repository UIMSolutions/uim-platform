/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.dto;
// import uim.platform.management.domain.types;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// --- Global Account DTOs ---

struct CreateGlobalAccountRequest {
  TenantId tenantId;

  string displayName;
  string description;
  string contractNumber;
  string licenseType; // "enterprise", "trial", "partner"
  string region;
  string costCenter;
  string companyName;
  string contactEmail;
  int maxSubaccounts = 100;
  int maxDirectories = 20;
  UserId createdBy;
  string[string] customProperties;
}

struct UpdateGlobalAccountRequest {
  TenantId tenantId;
  GlobalAccountId accountId;

  string displayName;
  string description;
  string costCenter;
  string contactEmail;
  string[string] customProperties;
}
/// --- Directory DTOs ---
struct CreateDirectoryRequest {
  TenantId tenantId;
  GlobalAccountId accountId;
  DirectoryId parentDirectoryId;
  
  string displayName;
  string description;
  string[] features; // "entitlements", "authorizations"
  bool manageEntitlements;
  bool manageAuthorizations;
  UserId createdBy;
  string[string] labels;
  string[string] customProperties;
}

struct UpdateDirectoryRequest {
  TenantId tenantId;
  DirectoryId directoryId;

  string displayName;
  string description;
  string[string] labels;
  string[string] customProperties;
}
/// --- Subaccount DTOs ---

struct CreateSubaccountRequest {
  TenantId tenantId;
  GlobalAccountId globalAccountId;
  DirectoryId parentDirectoryId;

  string displayName;
  string description;
  string subdomain;
  string region;
  string usage; // "production", "development", "test"
  bool betaEnabled = false;
  bool usedForProduction = false;
  UserId createdBy;
  string[string] labels;
  string[string] customProperties;
}

struct UpdateSubaccountRequest {
  TenantId tenantId;
  SubaccountId subaccountId;

  string displayName;
  string description;
  string usage;
  bool betaEnabled;
  bool usedForProduction;
  string[string] labels;
  string[string] customProperties;
}

struct MoveSubaccountRequest {
  GlobalAccountId globalAccountId;
  TenantId tenantId;
  SubaccountId subaccountId;
  DirectoryId targetDirectoryId; // empty = move to global account root
}
/// --- Entitlement DTOs ---

struct AssignEntitlementRequest {
  TenantId tenantId;
  GlobalAccountId globalAccountId;
  DirectoryId directoryId;
  SubaccountId subaccountId;
  ServicePlanId servicePlanId;

  string serviceName;
  string planName;
  int quotaAssigned;
  bool unlimited;
  bool autoAssign;
  UserId assignedBy;
}

struct UpdateEntitlementQuotaRequest {
  TenantId tenantId;
  EntitlementId entitlementId;

  int quotaAssigned;
  bool unlimited;
}
/// --- Environment Instance DTOs ---

struct CreateEnvironmentInstanceRequest {
  TenantId tenantId;
  SubaccountId subaccountId;
  GlobalAccountId globalAccountId;

  string name;
  string description;
  string environmentType; // "cloudFoundry", "kyma", "abap"
  string planName;
  string landscapeLabel;
  int memoryQuotaMb;
  int routeQuota;
  int serviceQuota;
  UserId createdBy;
  string[string] parameters;
  string[string] labels;
}

struct UpdateEnvironmentInstanceRequest {
  TenantId tenantId;
  EnvironmentInstanceId instanceId;

  string description;
  int memoryQuotaMb;
  int routeQuota;
  int serviceQuota;
  string[string] parameters;
  string[string] labels;
}
/// --- Subscription DTOs ---

struct CreateSubscriptionRequest {
  TenantId tenantId;
  SubaccountId subaccountId;
  GlobalAccountId globalAccountId;

  string appName;
  string planName;
  UserId subscribedBy;
  string[string] parameters;
  string[string] labels;
}

struct UpdateSubscriptionRequest {
  TenantId tenantId;
  SubscriptionId subscriptionId;

  string planName;
  string[string] parameters;
}
/// --- Service Plan DTOs ---

struct CreateServicePlanRequest {
  TenantId tenantId;

  string serviceName;
  string serviceDisplayName;
  string planName;
  string planDisplayName;
  string description;
  string category; // "service", "application", "environment"
  string pricingModel; // "free", "subscription", "consumption"
  bool isFree;
  bool isBeta;
  string[] availableRegions;
  int maxQuota;
  string unit;
  string[] supportedPlatforms;
  string providerDisplayName;
  string[string] metadata;
}

struct UpdateServicePlanRequest {
  TenantId tenantId;
  ServicePlanId planId;

  string planDisplayName;
  string description;
  string[] availableRegions;
  int maxQuota;
  bool isBeta;
  bool provisionable;
  string[string] metadata;
}
/// --- Label DTOs ---

struct CreateLabelRequest {
  TenantId tenantId;

  string resourceType; // "globalAccount", "directory", "subaccount"
  string resourceId;
  string key;
  string[] values;
  UserId createdBy;
}

struct UpdateLabelRequest {
  TenantId tenantId;
  LabelId labelId;

  string[] values;
}
/// --- Platform Event DTOs ---

struct QueryEventsRequest {
  TenantId tenantId;
  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
  string category;
  string severity;
  long sinceTimestamp;
}
/// --- Dashboard/overview DTOs ---

struct AccountOverview {
  size_t totalSubaccounts;
  size_t activeSubaccounts;
  size_t totalDirectories;
  size_t totalEntitlements;
  size_t totalEnvironments;
  size_t totalSubscriptions;
  size_t recentEventsCount;
}
