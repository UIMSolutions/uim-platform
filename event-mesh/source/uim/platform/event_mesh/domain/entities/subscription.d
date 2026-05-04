/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.subscription;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct EventSubscription {
    mixin TenantEntity!EventSubscriptionId;

    BrokerServiceId brokerServiceId;
    TopicId topicId;
    QueueId queueId;
    EventApplicationId applicationId;
    string name;
    string description;
    SubscriptionStatus status = SubscriptionStatus.active;
    SubscriptionType subscriptionType = SubscriptionType.direct;
    DeliveryMode deliveryMode = DeliveryMode.persistent;
    string topicFilter;
    string selector;
    string maxRedeliveryCount;
    string maxTtl;
    string lastMessageTime;
    string messageCount;

    Json toJson() const {
        return entityToJson()
            .set("brokerServiceId", brokerServiceId)
            .set("topicId", topicId)
            .set("queueId", queueId)
            .set("applicationId", applicationId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("subscriptionType", subscriptionType.to!string)
            .set("deliveryMode", deliveryMode.to!string)
            .set("topicFilter", topicFilter)
            .set("selector", selector)
            .set("maxRedeliveryCount", maxRedeliveryCount)
            .set("maxTtl", maxTtl)
            .set("lastMessageTime", lastMessageTime)
            .set("messageCount", messageCount);
    }
}
