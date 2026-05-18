/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.entities.subscription_job;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

/// Tracks the status of an asynchronous subscribe / unsubscribe / update operation.
class SubscriptionJob {
    mixin TenantEntity!(SubscriptionJobId);

    string    appName;        /// Application being subscribed / unsubscribed
    string    subscriptionId; /// Related AppSubscription record ID
    JobType   jobType;
    JobStatus jobStatus;
    int       progress;       /// 0–100
    string    message;        /// Human-readable status description
    long      startedAt;
    long      finishedAt;
    string    error;

    Json toJson() {
        import std.conv : to;
        auto j = Json.emptyObject;
        j["id"]             = Json(id.value);
        j["tenantId"]       = Json(tenantId);
        j["appName"]        = Json(appName);
        j["subscriptionId"] = Json(subscriptionId);
        j["jobType"]        = Json(jobType.to!string);
        j["jobStatus"]      = Json(jobStatus.to!string);
        j["progress"]       = Json(progress);
        j["message"]        = Json(message);
        j["startedAt"]      = Json(startedAt);
        j["finishedAt"]     = Json(finishedAt);
        j["error"]          = Json(error);
        j["createdAt"]      = Json(createdAt);
        j["updatedAt"]      = Json(updatedAt);
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
