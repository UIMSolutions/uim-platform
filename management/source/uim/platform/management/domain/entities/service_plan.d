module uim.platform.management.domain.entities.service_plan;

import uim.platform.management.domain.types;

/// A service plan represents an available service offering in the
/// BTP service marketplace with its pricing and capabilities.
struct ServicePlan {
    ServicePlanId id;
    string serviceName; // e.g. "xsuaa", "hana-cloud", "connectivity"
    string serviceDisplayName;
    string planName; // e.g. "application", "lite", "standard"
    string planDisplayName;
    string description;
    ServicePlanCategory category = ServicePlanCategory.service;
    PricingModel pricingModel = PricingModel.free;
    bool isFree = false;
    bool isBeta = false;
    string[] availableRegions; // regions where this plan is available
    int maxQuota = 0; // 0 = unlimited
    string unit; // "instances", "GB", "users", etc.
    string[] supportedPlatforms; // "cloudfoundry", "kyma", "other"
    string providerDisplayName;
    string dataCenter;
    string catalogUrl;
    bool provisionable = true;
    long createdAt;
    long modifiedAt;
    string[string] metadata;
}
