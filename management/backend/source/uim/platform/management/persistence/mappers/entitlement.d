/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.entitlement;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between Entitlement and its snapshot record.
struct EntitlementMapper {
  static Json toRecord(const Entitlement e) {
    auto r = baseRecord(e);
    r["globalAccountId"] = e.globalAccountId.value;
    r["directoryId"] = e.directoryId.value;
    r["subaccountId"] = e.subaccountId.value;
    r["servicePlanId"] = e.servicePlanId.value;
    r["serviceName"] = e.serviceName;
    r["planName"] = e.planName;
    r["planDisplayName"] = e.planDisplayName;
    r["category"] = enumName(e.category);
    r["status"] = enumName(e.status);
    r["quotaAssigned"] = e.quotaAssigned;
    r["quotaUsed"] = e.quotaUsed;
    r["quotaRemaining"] = e.quotaRemaining;
    r["unlimited"] = e.unlimited;
    r["autoAssign"] = e.autoAssign;
    r["assignedAt"] = e.assignedAt;
    r["assignedBy"] = e.assignedBy.value;
    return r;
  }

  static Entitlement fromRecord(Json r) {
    Entitlement e;
    readBase(e, r);
    e.globalAccountId = GlobalAccountId(fieldString(r, "globalAccountId"));
    e.directoryId = DirectoryId(fieldString(r, "directoryId"));
    e.subaccountId = SubaccountId(fieldString(r, "subaccountId"));
    e.servicePlanId = ServicePlanId(fieldString(r, "servicePlanId"));
    e.serviceName = fieldString(r, "serviceName");
    e.planName = fieldString(r, "planName");
    e.planDisplayName = fieldString(r, "planDisplayName");
    e.category = fieldEnum!ServicePlanCategory(r, "category", ServicePlanCategory.service);
    e.status = fieldEnum!EntitlementStatus(r, "status", EntitlementStatus.active);
    e.quotaAssigned = fieldInt(r, "quotaAssigned");
    e.quotaUsed = fieldInt(r, "quotaUsed");
    e.quotaRemaining = fieldInt(r, "quotaRemaining");
    e.unlimited = fieldBool(r, "unlimited");
    e.autoAssign = fieldBool(r, "autoAssign");
    e.assignedAt = fieldLong(r, "assignedAt");
    e.assignedBy = UserId(fieldString(r, "assignedBy"));
    return e;
  }
}
