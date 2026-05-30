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
        return Json.emptyObject
            .set("id",             id.value)
            .set("tenantId",       tenantId.value)
            .set("subscriptionId", subscriptionId.value)
            .set("filterType",     filterType.to!string)
            .set("attribute",      attribute)
            .set("operator",       operator_.to!string)
            .set("value",          value)
            .set("active",         active)
            .set("createdAt",      createdAt)
            .set("createdBy",      createdBy.value);
    }
}
