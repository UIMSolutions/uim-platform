/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.entities.condition;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

/// A filter rule that matches an event property against a value.
class Condition {
    mixin TenantEntity!(ConditionId);

    string      name;
    string      description;
    PropertyKey propertyKey;
    Predicate   predicate;
    string      propertyValue;
    bool        mandatory;    /// If true, must match for subscription to trigger
    string[]    labels;

    /// Evaluate whether this condition matches the given event.
    bool matches(AlertEvent event) {
        import std.string : toLower, indexOf;
        import std.conv   : to;

        if (predicate == Predicate.any_) return true;

        string actual;
        final switch (propertyKey) {
            case PropertyKey.eventType:        actual = event.eventType; break;
            case PropertyKey.eventCategory:    actual = event.category.to!string; break;
            case PropertyKey.eventSeverity:    actual = event.severity.to!string; break;
            case PropertyKey.resourceName:     actual = event.affectedResource.name; break;
            case PropertyKey.resourceType:     actual = event.affectedResource.type_; break;
            case PropertyKey.resourceInstance: actual = event.affectedResource.instance_; break;
            case PropertyKey.tags:
                // Check if any tag value matches
                foreach (v; event.tags)
                    if (v == propertyValue) return predicate != Predicate.notEquals;
                return predicate == Predicate.notEquals || predicate == Predicate.notContains;
        }

        final switch (predicate) {
            case Predicate.equals:      return actual == propertyValue;
            case Predicate.notEquals:   return actual != propertyValue;
            case Predicate.contains:    return actual.indexOf(propertyValue) >= 0;
            case Predicate.notContains: return actual.indexOf(propertyValue) < 0;
            case Predicate.any_:        return true;
        }
    }

    Json toJson() {
        
        auto j = Json.emptyObject;
        j["id"]            = id.value;
        j["tenantId"]      = tenantId.toString();
        j["name"]          = name;
        j["description"]   = description;
        j["propertyKey"]   = propertyKey.to!string;
        j["predicate"]     = predicate.to!string;
        j["propertyValue"] = propertyValue;
        j["mandatory"]     = mandatory;
        j["createdAt"]     = createdAt;
        j["updatedAt"]     = updatedAt;
        auto lbls = Json.emptyArray;
        foreach (l; labels) lbls ~= Json(l);
        j["labels"] = lbls;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
