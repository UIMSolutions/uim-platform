/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.entities.action;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

/// A delivery action triggered when a subscription matches an event.
class Action {
    mixin TenantEntity!(ActionId);

    string        name;
    string        description;
    ActionType    type_;
    ResourceState state;
    string[string] properties;       /// Channel-specific config (destination URL, recipients, etc.)
    string[]      labels;
    string        fallbackAction;    /// Name of another Action to use on failure
    bool          enableDeliveryStatus; /// Persist delivery attempt outcomes

    bool isEnabled() { return state == ResourceState.enabled; }

    Json toJson() {
        
        auto j = Json.emptyObject;
        j["id"]                   = id.value;
        j["tenantId"]             = tenantId;
        j["name"]                 = name;
        j["description"]          = description;
        j["type"]                 = type_.to!string;
        j["state"]                = state.to!string;
        j["fallbackAction"]       = fallbackAction;
        j["enableDeliveryStatus"] = enableDeliveryStatus;
        j["createdAt"]            = createdAt;
        j["updatedAt"]            = updatedAt;
        auto props = Json.emptyObject;
        foreach (k, v; properties) props[k] = Json(v);
        j["properties"] = props;
        auto lbls = Json.emptyArray;
        foreach (l; labels) lbls ~= Json(l);
        j["labels"] = lbls;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
