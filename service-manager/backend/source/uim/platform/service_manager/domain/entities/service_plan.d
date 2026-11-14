/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.service_plan;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// A capability tier of a service offering.
struct ServicePlan {
  mixin TenantEntity!ServicePlanId;

  ServiceOfferingId offeringId;
  string name;
  string description;
  string catalogId; /// broker side id (OSB plan id)
  string catalogName;
  ServicePlanPricing pricing = ServicePlanPricing.free;
  bool bindable = true;
  bool planUpdateable = true;
  int maxInstances; /// quota per tenant, 0 = unlimited
  string schemas; /// JSON text (OSB parameter schemas)
  string metadata; /// JSON text

  bool free() const {
    return pricing == ServicePlanPricing.free;
  }

  /// True if `existing` instances already exhaust the quota.
  bool quotaExhausted(size_t existing) const {
    return maxInstances > 0 && existing >= cast(size_t) maxInstances;
  }

  void validate() const {
    requireName(name, "Service plan");
    if (offeringId.isNull)
      throw ServiceManagerException.invalid("Service plan offeringId is required");
    if (maxInstances < 0)
      throw ServiceManagerException.invalid("Service plan maxInstances must not be negative");
    requireJsonText(schemas, "schemas");
    requireJsonText(metadata, "metadata");
  }
}

///
unittest {
  ServicePlan p;
  p.maxInstances = 2;
  assert(!p.quotaExhausted(1) && p.quotaExhausted(2));
  p.maxInstances = 0;
  assert(!p.quotaExhausted(1000));
  assert(p.free);
}
