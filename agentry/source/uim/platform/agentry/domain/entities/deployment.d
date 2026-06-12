/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.entities.deployment;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct Deployment {
    mixin TenantEntity!(DeploymentId);

    MobileApplicationId mobileApplicationId;
    AppVersionId appVersionId;
    DeploymentStatus status = DeploymentStatus.pending;
    DeploymentScope scope_ = DeploymentScope.tenant;
    string targetDeviceId;
    string targetGroupName;
    long scheduledAt;
    long startedAt;
    long completedAt;
    string rollbackVersionId;
    UserId deployedBy;
    string notes;
    long devicesTotal;
    long devicesSucceeded;
    long devicesFailed;

    Json toJson() const {
        auto j = entityToJson
            .set("mobileApplicationId", mobileApplicationId.value)
            .set("appVersionId", appVersionId.value)
            .set("status", status.to!string)
            .set("scope", scope_.to!string)
            .set("targetDeviceId", targetDeviceId)
            .set("targetGroupName", targetGroupName)
            .set("scheduledAt", scheduledAt)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("rollbackVersionId", rollbackVersionId)
            .set("deployedBy", deployedBy.value)
            .set("notes", notes)
            .set("devicesTotal", devicesTotal)
            .set("devicesSucceeded", devicesSucceeded)
            .set("devicesFailed", devicesFailed);
        return j;
    }
}
