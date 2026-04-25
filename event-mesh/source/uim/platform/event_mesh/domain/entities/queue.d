/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.queue;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct Queue {
    QueueId id;
    TenantId tenantId;
    BrokerServiceId brokerServiceId;
    string name;
    string description;
    QueueType queueType = QueueType.durable;
    QueueAccessType accessType = QueueAccessType.exclusive;
    QueueStatus status = QueueStatus.active;
    string maxMsgSpoolUsage;
    string maxBindCount;
    string maxMsgSize;
    string maxRedeliveryCount;
    string maxTtl;
    string deadMessageQueue;
    string owner;
    string permission;
    string egressEnabled;
    string ingressEnabled;
    string currentSpoolUsage;
    string messageCount;
    string bindCount;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string updatedAt;

    Json queueToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("brokerServiceId", brokerServiceId)
            .set("name", name)
            .set("description", description)
            .set("queueType", queueType.to!string)
            .set("accessType", accessType.to!string)
            .set("status", status.to!string)
            .set("maxMsgSpoolUsage", maxMsgSpoolUsage)
            .set("maxBindCount", maxBindCount)
            .set("maxMsgSize", maxMsgSize)
            .set("maxRedeliveryCount", maxRedeliveryCount)
            .set("maxTtl", maxTtl)
            .set("deadMessageQueue", deadMessageQueue)
            .set("owner", owner)
            .set("permission", permission)
            .set("egressEnabled", egressEnabled)
            .set("ingressEnabled", ingressEnabled)
            .set("currentSpoolUsage", currentSpoolUsage)
            .set("messageCount", messageCount)
            .set("bindCount", bindCount)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
}
