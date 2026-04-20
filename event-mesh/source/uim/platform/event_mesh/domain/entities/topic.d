/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.topic;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct Topic {
    mixin TenantEntity!(TopicId);
    
    BrokerServiceId brokerServiceId;
    string name;
    string description;
    TopicStatus status = TopicStatus.active;
    string topicString;
    string maxMessageSize;
    string publishEnabled;
    string subscribeEnabled;
    string subscriberCount;
    string publishRate;
    string subscribeRate;
    string retainedMessage;
    
    Json toJson() const {
        return entityToJson
            .set("brokerServiceId", brokerServiceId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("topicString", topicString)
            .set("maxMessageSize", maxMessageSize)
            .set("publishEnabled", publishEnabled)
            .set("subscribeEnabled", subscribeEnabled)
            .set("subscriberCount", subscriberCount)
            .set("publishRate", publishRate)
            .set("subscribeRate", subscribeRate)
            .set("retainedMessage", retainedMessage);
    }
}
