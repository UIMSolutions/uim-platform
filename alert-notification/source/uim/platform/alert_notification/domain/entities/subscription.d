/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.entities.subscription;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

/// Links a set of conditions to a set of actions — the routing rule.
class Subscription {
    mixin TenantEntity!(SubscriptionId);

    string        name;
    string        description;
    string[]      conditions;  /// Names of Condition objects that must match
    string[]      actions;     /// Names of Action objects to invoke on match
    ResourceState state;
    string[]      labels;

    bool isEnabled() { return state == ResourceState.enabled; }

    Json toJson() {
        
        auto j = Json.emptyObject;
        j["id"]          = id.value;
        j["tenantId"]    = tenantId;
        j["name"]        = name;
        j["description"] = description;
        j["state"]       = state.to!string;
        j["createdAt"]   = createdAt;
        j["updatedAt"]   = updatedAt;
        auto conds = Json.emptyArray;
        foreach (c; conditions) conds ~= Json(c);
        j["conditions"] = conds;
        auto acts = Json.emptyArray;
        foreach (a; actions) acts ~= Json(a);
        j["actions"] = acts;
        auto lbls = Json.emptyArray;
        foreach (l; labels) lbls ~= Json(l);
        j["labels"] = lbls;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
