/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.models.event_subscription;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_subscription;

@safe:

class WebEventSubscriptionModel {
    EventSubscription[] items;
    EventSubscription   selected;
    bool                hasSelected;
    string              errorMessage;
    string              successMessage;
    string              title;

    void setItems(EventSubscription[] list) { items = list; errorMessage = ""; title = "Event Subscriptions"; }

    void setSelected(EventSubscription item, bool found) {
        selected    = item;
        hasSelected = found;
        title       = found ? "Event Subscription: " ~ item.name : "Not Found";
        errorMessage = found ? "" : "Event subscription not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; title = "Error"; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
