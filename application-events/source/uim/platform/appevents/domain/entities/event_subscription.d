/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_subscription;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.subscription_status;
import uim.platform.appevents.domain.enums.formation_status;
import vibe.data.json;
import std.conv : to;

@safe:

struct EventSubscription {
    mixin TenantEntity!(EventSubscriptionId);

    string name;
    string description;
    string producerSystemId;
    string consumerSystemId;
    string eventType;
    SubscriptionStatus status;
    FormationId formationId;
    string filterExpression;
    int maxRetries = 3;
    long createdAt;
    long updatedAt;

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["id"]               = id.value;
        j["tenantId"]         = tenantId.value;
        j["name"]             = name;
        j["description"]      = description;
        j["producerSystemId"] = producerSystemId;
        j["consumerSystemId"] = consumerSystemId;
        j["eventType"]        = eventType;
        j["status"]           = status.to!string;
        j["formationId"]      = formationId.value;
        j["filterExpression"] = filterExpression;
        j["maxRetries"]       = maxRetries;
        j["createdAt"]        = createdAt;
        j["updatedAt"]        = updatedAt;
        return j;
    }
}
