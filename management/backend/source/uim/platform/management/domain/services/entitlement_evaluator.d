/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.services.entitlement_evaluator;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Result of quota validation.
struct QuotaValidation {
  bool valid;
  string reason;
}

/// Domain service: evaluates entitlement quota constraints against the
/// maximum quota of a service plan.
class EntitlementEvaluator {
  /// Check if a quota assignment is valid.
  /// maxAvailable <= 0 means the plan has no global limit.
  QuotaValidation validateQuotaAssignment(int requestedQuota, int currentlyAssigned, int maxAvailable, bool unlimited) const {
    if (unlimited)
      return QuotaValidation(true, "");
    if (requestedQuota <= 0)
      return QuotaValidation(false, "Requested quota must be greater than zero");
    if (maxAvailable > 0 && currentlyAssigned + requestedQuota > maxAvailable)
      return QuotaValidation(false, "Insufficient quota: requested " ~ requestedQuota.to!string ~ ", available "
          ~ (maxAvailable - currentlyAssigned > 0 ? maxAvailable - currentlyAssigned : 0).to!string
          ~ " of " ~ maxAvailable.to!string);
    return QuotaValidation(true, "");
  }

  /// Validate a new assignment of the plan, given the entitlements that already exist for it.
  /// "except" is excluded from the sum (used when re-assigning an existing entitlement).
  QuotaValidation validate(const ServicePlan plan, const Entitlement[] existing, int requestedQuota,
      bool unlimited, EntitlementId except = EntitlementId.init) const {
    if (!plan.provisionable)
      return QuotaValidation(false, "Service plan '" ~ plan.serviceName ~ "/" ~ plan.planName ~ "' is not provisionable");
    if (plan.status != ServicePlanStatus.active)
      return QuotaValidation(false, "Service plan '" ~ plan.serviceName ~ "/" ~ plan.planName ~ "' is " ~ enumName(plan.status));
    if (unlimited && !plan.isUnlimited)
      return QuotaValidation(false, "Service plan '" ~ plan.planName ~ "' is limited to " ~ plan.maxQuota.to!string ~ " " ~ plan.unit);
    return validateQuotaAssignment(requestedQuota, assignedQuota(existing, except), plan.maxQuota, unlimited);
  }

  /// Sum of the quota assigned by entitlements that still consume quota.
  int assignedQuota(const Entitlement[] existing, EntitlementId except = EntitlementId.init) const {
    int sum;
    foreach (e; existing)
      if (e.consumesQuota && !e.unlimited && e.id != except)
        sum += e.quotaAssigned;
    return sum;
  }

  /// Calculate remaining quota after an assignment.
  int calculateRemaining(int assigned, int used) const {
    auto rem = assigned - used;
    return rem > 0 ? rem : 0;
  }

  /// Check if an entitlement has exceeded its quota.
  bool isOverQuota(const Entitlement ent) const {
    return ent.isOverQuota;
  }
}

///
unittest {
  mixin(ShowTest!("EntitlementEvaluator"));

  auto ev = new EntitlementEvaluator();
  auto plan = ServicePlan(TenantId("t"));
  plan.serviceName = "hana-cloud";
  plan.planName = "hana";
  plan.maxQuota = 10;

  auto e1 = Entitlement(TenantId("t"));
  e1.quotaAssigned = 6;
  auto revoked = Entitlement(TenantId("t"));
  revoked.quotaAssigned = 100;
  revoked.status = EntitlementStatus.revoked;

  assert(ev.validate(plan, [e1, revoked], 4, false).valid);
  assert(!ev.validate(plan, [e1, revoked], 5, false).valid);
  assert(ev.validate(plan, [e1], 10, false, e1.id).valid); // re-assign e1 itself
  assert(!ev.validate(plan, [], 1, true).valid); // limited plan cannot be unlimited

  plan.maxQuota = 0;
  assert(ev.validate(plan, [e1], 1000, false).valid);
  assert(!ev.validateQuotaAssignment(0, 0, 0, false).valid);
}
