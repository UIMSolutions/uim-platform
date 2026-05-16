/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.entities.replication;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

struct Replication {
    mixin TenantEntity!(ReplicationId);

    BusinessPartnerId businessPartnerId;
    string targetSystem;
    string targetSystemType;
    ReplicationType replicationType = ReplicationType.delta;
    ReplicationStatus status = ReplicationStatus.pending;
    UserId triggeredBy;
    long scheduledAt;
    string startedAt;
    long completedAt;
    string errorMessage;
    string replicatedFields;
    int retryCount;
    int maxRetries;
    string correlationId;
    string batchId;

    Json toJson() const {
        return entityToJson
            .set("businessPartnerId", businessPartnerId.value)
            .set("targetSystem", targetSystem)
            .set("targetSystemType", targetSystemType)
            .set("replicationType", replicationType.to!string)
            .set("status", status.to!string)
            .set("triggeredBy", triggeredBy.value)
            .set("scheduledAt", scheduledAt)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("errorMessage", errorMessage)
            .set("replicatedFields", replicatedFields)
            .set("retryCount", retryCount)
            .set("maxRetries", maxRetries)
            .set("correlationId", correlationId)
            .set("batchId", batchId);
    }
}
