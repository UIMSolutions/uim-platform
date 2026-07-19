/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.event_channel;

import uim.platform.events;
mixin(ShowModule!());

@safe:

struct EventChannel {
    mixin TenantEntity!EventChannelId;

    MessagingServiceId serviceId;
    string name;
    string description;
    EventChannelStatus status = EventChannelStatus.active;
    EventChannelType channelType = EventChannelType.topic;
    string namespace;
    string topicName;
    string asyncapiDefinition;
    string maxRetentionPeriod;
    string maxPartitions;

    Json toJson() const {
        return entityToJson
            .set("serviceId", serviceId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("channelType", channelType.to!string)
            .set("namespace", namespace)
            .set("topicName", topicName)
            .set("asyncapiDefinition", asyncapiDefinition)
            .set("maxRetentionPeriod", maxRetentionPeriod)
            .set("maxPartitions", maxPartitions);
    }
}
