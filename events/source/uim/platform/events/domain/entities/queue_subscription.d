/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.queue_subscription;

import uim.platform.events;
mixin(ShowModule!());

@safe:

struct QueueSubscription {
    mixin TenantEntity!QueueSubscriptionId;

    QueueId queueId;
    MessagingServiceId serviceId;
    string name;
    string description;
    QueueSubscriptionStatus status = QueueSubscriptionStatus.active;
    string topicPattern;
    string namespace;

    Json toJson() const {
        return entityToJson
            .set("queueId", queueId.value)
            .set("serviceId", serviceId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("topicPattern", topicPattern)
            .set("namespace", namespace);
    }
}
