/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.messaging_service;

import uim.platform.events;
mixin(ShowModule!());

@safe:

struct MessagingService {
    mixin TenantEntity!MessagingServiceId;

    string name;
    string description;
    string namespace;
    MessagingServiceStatus status = MessagingServiceStatus.creating;
    MessagingServicePlan plan = MessagingServicePlan.dev;
    string region;
    string datacenter;
    string version_;
    string maxConnections;
    string maxQueues;
    string maxQueueDepth;
    string maxMessageSize;
    string tokenEndpoint;
    string messagingEndpoint;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("namespace", namespace)
            .set("status", status.to!string)
            .set("plan", plan.to!string)
            .set("region", region)
            .set("datacenter", datacenter)
            .set("version", version_)
            .set("maxConnections", maxConnections)
            .set("maxQueues", maxQueues)
            .set("maxQueueDepth", maxQueueDepth)
            .set("maxMessageSize", maxMessageSize)
            .set("tokenEndpoint", tokenEndpoint)
            .set("messagingEndpoint", messagingEndpoint);
    }
}
