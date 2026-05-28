/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// A service plan represents an available service offering in the
/// BTP service marketplace with its pricing and capabilities.
struct ServicePlan {
  mixin TenantEntity!ServicePlanId;

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
  string[string] metadata;

  Json toJson() const {
    auto jMetadata = Json.emptyObject;
    foreach (key, value; metadata) {
      jMetadata.set(key, value);
    }

    return entityToJson
      .set("serviceName", serviceName)
      .set("serviceDisplayName", serviceDisplayName)
      .set("planName", planName)
      .set("planDisplayName", planDisplayName)
      .set("description", description)
      .set("category", category.to!string())
      .set("pricingModel", pricingModel.to!string())
      .set("isFree", isFree)
      .set("isBeta", isBeta)
      .set("availableRegions", availableRegions.toJson)
      .set("maxQuota", maxQuota)
      .set("unit", unit)
      .set("supportedPlatforms", supportedPlatforms.toJson)
      .set("providerDisplayName", providerDisplayName)
      .set("dataCenter", dataCenter)
      .set("catalogUrl", catalogUrl)
      .set("provisionable", provisionable)
      .set("metadata", jMetadata);
  }
}
