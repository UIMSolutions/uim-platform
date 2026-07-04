/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.entities.matched_event;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

/// An event stored by a STORE action — retrievable via the Consumer (pull) API.
class MatchedEvent {
    mixin TenantEntity!(MatchedEventId);

    string        eventId;
    string        eventType;
    EventCategory category;
    EventSeverity severity;
    string        subject;
    string        body;
    string        region;
    string        subscriptionName;
    string        actionName;
    long          storedAt;          /// Unix epoch seconds
    long          retentionPeriod;   /// Seconds until expiry (default: 7 days)
    AffectedResource affectedResource;
    string[string] tags;

    Json toJson() {
        
        auto j = Json.emptyObject;
        j["id"]               = id.value;
        j["tenantId"]         = tenantId.toString();
        j["eventId"]          = eventId;
        j["eventType"]        = eventType;
        j["category"]         = category.to!string;
        j["severity"]         = severity.to!string;
        j["subject"]          = subject;
        j["body"]             = body;
        j["region"]           = region;
        j["subscriptionName"] = subscriptionName;
        j["actionName"]       = actionName;
        j["storedAt"]         = storedAt;
        j["retentionPeriod"]  = retentionPeriod;
        j["affectedResource"] = affectedResource.toJson();
        auto t = Json.emptyObject;
        foreach (k, v; tags) t[k] = Json(v);
        j["tags"] = t;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
