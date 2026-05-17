/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.entities.sync_session;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct SyncSession {
    mixin TenantEntity!(SyncSessionId);

    DeviceId deviceId;
    MobileApplicationId mobileApplicationId;
    BackendConnectionId backendConnectionId;
    SyncStatus status = SyncStatus.pending;
    SyncDirection direction = SyncDirection.bidirectional;
    string startedAt;
    string completedAt;
    long bytesSent;
    long bytesReceived;
    long recordsSent;
    long recordsReceived;
    string errorMessage;
    string clientAppVersion;
    string triggeredBy;   // manual, scheduled, push

    Json toJson() const {
        auto j = entityToJson
            .set("deviceId", deviceId.value)
            .set("mobileApplicationId", mobileApplicationId.value)
            .set("backendConnectionId", backendConnectionId.value)
            .set("status", status.to!string)
            .set("direction", direction.to!string)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("bytesSent", bytesSent)
            .set("bytesReceived", bytesReceived)
            .set("recordsSent", recordsSent)
            .set("recordsReceived", recordsReceived)
            .set("errorMessage", errorMessage)
            .set("clientAppVersion", clientAppVersion)
            .set("triggeredBy", triggeredBy);
        return j;
    }
}
