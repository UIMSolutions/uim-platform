/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.entitlement;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// An entitlement represents the assignment of a service plan's quota
/// to a global account, directory, or subaccount.
struct Entitlement {
  mixin TenantEntity!EntitlementId;

  GlobalAccountId globalAccountId;
  DirectoryId directoryId; // optional — directory-level entitlement
  SubaccountId subaccountId; // optional — subaccount-level assignment
  ServicePlanId servicePlanId;
  string serviceName;
  string planName;
  string planDisplayName;
  ServicePlanCategory category = ServicePlanCategory.service;
  EntitlementStatus status = EntitlementStatus.active;
  int quotaAssigned = 0; // assigned quota units
  int quotaUsed = 0;
  int quotaRemaining = 0;
  bool unlimited = false;
  bool autoAssign = false; // auto-assign to new subaccounts
  long assignedAt; // stdTime
  UserId assignedBy;

  /// True if the entitlement still consumes quota of its service plan.
  bool consumesQuota() const {
    return status == EntitlementStatus.active || status == EntitlementStatus.pending;
  }

  bool isOverQuota() const {
    return !unlimited && quotaUsed > quotaAssigned;
  }

  /// Change the assigned quota (remaining is recalculated).
  void reassign(int quota, bool isUnlimited, UserId by) {
    if (status == EntitlementStatus.revoked)
      throw new InvalidStateTransition("Entitlement", enumName(status), "change its quota");
    quotaAssigned = quota;
    unlimited = isUnlimited;
    quotaRemaining = quotaAssigned - quotaUsed > 0 ? quotaAssigned - quotaUsed : 0;
    update(by);
  }

  /// active/pending → revoked
  void revoke(UserId by) {
    if (status == EntitlementStatus.revoked)
      throw new InvalidStateTransition("Entitlement", enumName(status), "be revoked");
    status = EntitlementStatus.revoked;
    update(by);
  }

  Json toJson() const {
    return entityToJson()
      .set("globalAccountId", globalAccountId.value)
      .set("directoryId", directoryId.value)
      .set("subaccountId", subaccountId.value)
      .set("servicePlanId", servicePlanId.value)
      .set("serviceName", serviceName)
      .set("planName", planName)
      .set("planDisplayName", planDisplayName)
      .set("category", enumName(category))
      .set("status", enumName(status))
      .set("quotaAssigned", quotaAssigned)
      .set("quotaUsed", quotaUsed)
      .set("quotaRemaining", quotaRemaining)
      .set("unlimited", unlimited)
      .set("autoAssign", autoAssign)
      .set("assignedAt", assignedAt)
      .set("assignedBy", assignedBy.value);
  }
}

///
unittest {
  mixin(ShowTest!("Entitlement"));

  auto e = Entitlement(TenantId("t1"));
  e.quotaUsed = 3;
  e.reassign(2, false, UserId("u"));
  assert(e.isOverQuota && e.quotaRemaining == 0);
  e.revoke(UserId("u"));
  assert(!e.consumesQuota);
}
