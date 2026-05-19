/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_filter;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.filter_type;
import uim.platform.appevents.domain.enums.filter_operator;
import vibe.data.json;
import std.conv : to;

@safe:

struct EventFilter {
    mixin TenantEntity!(EventFilterId);

    EventSubscriptionId subscriptionId;
    FilterType filterType;
    string attribute;
    FilterOperator operator_;
    string value;
    bool active = true;

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["id"]             = id.value;
        j["tenantId"]       = tenantId.value;
        j["subscriptionId"] = subscriptionId.value;
        j["filterType"]     = filterType.to!string;
        j["attribute"]      = attribute;
        j["operator"]       = operator_.to!string;
        j["value"]          = value;
        j["active"]         = active;
        return j;
    }
}
