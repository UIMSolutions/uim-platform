/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_topic;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.topic_status;
import vibe.data.json;
import std.conv : to;

@safe:

struct EventTopic {
    mixin TenantEntity!(EventTopicId);

    string name;
    string namespace;
    string description;
    string version_;
    string category;
    TopicStatus status;
    string ownerId;

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["id"]          = id.value;
        j["tenantId"]    = tenantId.value;
        j["name"]        = name;
        j["namespace"]   = namespace;
        j["description"] = description;
        j["version"]     = version_;
        j["category"]    = category;
        j["status"]      = status.to!string;
        j["ownerId"]     = ownerId;
        return j;
    }
}
