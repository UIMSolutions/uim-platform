module application.dto;

import uim.platform.management.domain.types;

/// --- Command result ---

struct CommandResult {
    bool success;
    string id;
    string error;
}

/// --- Global Account DTOs ---

struct CreateGlobalAccountRequest {
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
    string createdBy;
    string[string] customProperties;
}

struct UpdateGlobalAccountRequest {
    string displayName;
    string description;
    string costCenter;
    string contactEmail;
    string[string] customProperties;
}

/// --- Directory DTOs ---

struct CreateDirectoryRequest {
    GlobalAccountId globalAccountId;
    DirectoryId parentDirectoryId;
    string displayName;
    string description;
    string[] features; // "entitlements", "authorizations"
    bool manageEntitlements;
    bool manageAuthorizations;
    string createdBy;
    string[string] labels;
    string[string] customProperties;
}

struct UpdateDirectoryRequest {
    string displayName;
    string description;
    string[string] labels;
    string[string] customProperties;
}

/// --- Subaccount DTOs ---

struct CreateSubaccountRequest {
    GlobalAccountId globalAccountId;
    DirectoryId parentDirectoryId;
    string displayName;
    string description;
    string subdomain;
    string region;
    string usage; // "production", "development", "test"
    bool betaEnabled = false;
    bool usedForProduction = false;
    string createdBy;
    string[string] labels;
    string[string] customProperties;
}

struct UpdateSubaccountRequest {
    string displayName;
    string description;
    string usage;
    bool betaEnabled;
    bool usedForProduction;
    string[string] labels;
    string[string] customProperties;
}

struct MoveSubaccountRequest {
    DirectoryId targetDirectoryId; // empty = move to global account root
}

/// --- Entitlement DTOs ---

struct AssignEntitlementRequest {
    GlobalAccountId globalAccountId;
    DirectoryId directoryId;
    SubaccountId subaccountId;
    ServicePlanId servicePlanId;
    string serviceName;
    string planName;
    int quotaAssigned;
    bool unlimited;
    bool autoAssign;
    string assignedBy;
}

struct UpdateEntitlementQuotaRequest {
    int quotaAssigned;
    bool unlimited;
}

/// --- Environment Instance DTOs ---

struct CreateEnvironmentInstanceRequest {
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
    string createdBy;
    string[string] parameters;
    string[string] labels;
}

struct UpdateEnvironmentInstanceRequest {
    string description;
    int memoryQuotaMb;
    int routeQuota;
    int serviceQuota;
    string[string] parameters;
    string[string] labels;
}

/// --- Subscription DTOs ---

struct CreateSubscriptionRequest {
    SubaccountId subaccountId;
    GlobalAccountId globalAccountId;
    string appName;
    string planName;
    string subscribedBy;
    string[string] parameters;
    string[string] labels;
}

struct UpdateSubscriptionRequest {
    string planName;
    string[string] parameters;
}

/// --- Service Plan DTOs ---

struct CreateServicePlanRequest {
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
    string resourceType; // "globalAccount", "directory", "subaccount"
    string resourceId;
    string key;
    string[] values;
    string createdBy;
}

struct UpdateLabelRequest {
    string[] values;
}

/// --- Platform Event DTOs ---

struct QueryEventsRequest {
    GlobalAccountId globalAccountId;
    SubaccountId subaccountId;
    string category;
    string severity;
    long sinceTimestamp;
}

/// --- Dashboard/overview DTOs ---

struct AccountOverview {
    long totalSubaccounts;
    long activeSubaccounts;
    long totalDirectories;
    long totalEntitlements;
    long totalEnvironments;
    long totalSubscriptions;
    long recentEventsCount;
}
