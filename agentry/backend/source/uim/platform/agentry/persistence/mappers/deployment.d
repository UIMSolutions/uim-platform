/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.persistence.mappers.deployment;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Deployment ⇄ snapshot record.
struct DeploymentMapper {
  static Json toRecord(const Deployment e) {
    auto r = baseRecord(e);
    r["mobileApplicationId"] = e.mobileApplicationId.value;
    r["appVersionId"] = e.appVersionId.value;
    r["status"] = enumValue(e.status);
    r["scope"] = enumValue(e.scope_);
    r["targetDeviceId"] = e.targetDeviceId;
    r["targetGroupName"] = e.targetGroupName;
    r["scheduledAt"] = e.scheduledAt;
    r["startedAt"] = e.startedAt;
    r["completedAt"] = e.completedAt;
    r["rollbackVersionId"] = e.rollbackVersionId;
    r["deployedBy"] = e.deployedBy.value;
    r["notes"] = e.notes;
    r["devicesTotal"] = e.devicesTotal;
    r["devicesSucceeded"] = e.devicesSucceeded;
    r["devicesFailed"] = e.devicesFailed;
    return r;
  }

  static Deployment fromRecord(Json r) {
    Deployment e;
    readBase(e, r);
    e.mobileApplicationId = MobileApplicationId(fieldString(r, "mobileApplicationId"));
    e.appVersionId = AppVersionId(fieldString(r, "appVersionId"));
    e.status = fieldEnum!DeploymentStatus(r, "status", DeploymentStatus.pending);
    e.scope_ = fieldEnum!DeploymentScope(r, "scope", DeploymentScope.tenant);
    e.targetDeviceId = fieldString(r, "targetDeviceId");
    e.targetGroupName = fieldString(r, "targetGroupName");
    e.scheduledAt = fieldLong(r, "scheduledAt");
    e.startedAt = fieldLong(r, "startedAt");
    e.completedAt = fieldLong(r, "completedAt");
    e.rollbackVersionId = fieldString(r, "rollbackVersionId");
    e.deployedBy = UserId(fieldString(r, "deployedBy"));
    e.notes = fieldString(r, "notes");
    e.devicesTotal = fieldLong(r, "devicesTotal");
    e.devicesSucceeded = fieldLong(r, "devicesSucceeded");
    e.devicesFailed = fieldLong(r, "devicesFailed");
    return e;
  }
}
