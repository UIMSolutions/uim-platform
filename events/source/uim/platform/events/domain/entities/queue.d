/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.queue;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

struct Queue {
    mixin TenantEntity!QueueId;

    MessagingServiceId serviceId;
    string name;
    string description;
    QueueStatus status = QueueStatus.active;
    QueueAccessType accessType = QueueAccessType.nonExclusive;
    string maxMessageSizeBytes;
    string maxQueueSizeBytes;
    string maxConsumers;
    string deadLetterQueue;
    string discardMessages;
    string maxRedeliveryCount;
    string messageExpiryTimer;
    string owner;
    string permission;
    bool egressEnabled = true;
    bool ingressEnabled = true;

    Json toJson() const {
        return entityToJson
            .set("serviceId", serviceId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("accessType", accessType.to!string)
            .set("maxMessageSizeBytes", maxMessageSizeBytes)
            .set("maxQueueSizeBytes", maxQueueSizeBytes)
            .set("maxConsumers", maxConsumers)
            .set("deadLetterQueue", deadLetterQueue)
            .set("discardMessages", discardMessages)
            .set("maxRedeliveryCount", maxRedeliveryCount)
            .set("messageExpiryTimer", messageExpiryTimer)
            .set("owner", owner)
            .set("permission", permission)
            .set("egressEnabled", egressEnabled)
            .set("ingressEnabled", ingressEnabled);
    }
}
