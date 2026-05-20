/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_subscription;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.subscription_status;
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

    Json toJson() const @safe {
        return Json.emptyObject
            .set("id",               id.value)
            .set("tenantId",         tenantId.value)
            .set("name",             name)
            .set("description",      description)
            .set("producerSystemId", producerSystemId)
            .set("consumerSystemId", consumerSystemId)
            .set("eventType",        eventType)
            .set("status",           status.to!string)
            .set("formationId",      formationId.value)
            .set("filterExpression", filterExpression)
            .set("maxRetries",       maxRetries)
            .set("createdAt",        createdAt)
            .set("createdBy",        createdBy.value)
            .set("updatedAt",        updatedAt)
            .set("updatedBy",        updatedBy.value);
    }
}
