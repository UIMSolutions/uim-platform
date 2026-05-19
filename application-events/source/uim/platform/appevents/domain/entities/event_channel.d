/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_channel;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.channel_type;
import uim.platform.appevents.domain.enums.channel_status;
import uim.platform.appevents.domain.enums.delivery_mode;
import vibe.data.json;
import std.conv : to;

@safe:

struct EventChannel {
    mixin TenantEntity!(EventChannelId);

    string name;
    EventTopicId topicId;
    ChannelType channelType;
    string endpoint;
    ChannelStatus status;
    DeliveryMode deliveryMode;
    long maxSizeBytes = 1_048_576;

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["id"]           = id.value;
        j["tenantId"]     = tenantId.value;
        j["name"]         = name;
        j["topicId"]      = topicId.value;
        j["channelType"]  = channelType.to!string;
        j["endpoint"]     = endpoint;
        j["status"]       = status.to!string;
        j["deliveryMode"] = deliveryMode.to!string;
        j["maxSizeBytes"] = maxSizeBytes;
        return j;
    }
}
