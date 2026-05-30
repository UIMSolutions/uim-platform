/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.entities.alert_event;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

/// A resource affected by the event — application or service instance.
struct AffectedResource {
    string name;
    string type_;
    string instance_;
    string[string] tags;

    Json toJson() {
        auto j = Json.emptyObject;
        j["name"]     = name;
        j["type"]     = type_;
        j["instance"] = instance_;
        auto t = Json.emptyObject;
        foreach (k, v; tags) t[k] = Json(v);
        j["tags"] = t;
        return j;
    }
}

/// A customer-produced or platform-produced event submitted to the service.
class AlertEvent {
    mixin TenantEntity!(AlertEventId);

    string        eventType;
    EventCategory category;
    EventSeverity severity;
    string        subject;
    string        body;
    string[string] tags;
    AffectedResource affectedResource;
    string        region;
    long          timestamp;    /// Unix epoch seconds
    EventStatus   status;

    Json toJson() {
        
        auto j = Json.emptyObject;
        j["id"]        = id.value;
        j["tenantId"]  = tenantId;
        j["eventType"] = eventType;
        j["category"]  = category.to!string;
        j["severity"]  = severity.to!string;
        j["subject"]   = subject;
        j["body"]      = body;
        j["region"]    = region;
        j["timestamp"] = timestamp;
        j["status"]    = status.to!string;
        auto t = Json.emptyObject;
        foreach (k, v; tags) t[k] = Json(v);
        j["tags"]             = t;
        j["affectedResource"] = affectedResource.toJson();
        j["createdAt"]        = createdAt;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
