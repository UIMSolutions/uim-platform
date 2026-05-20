/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.views.event_subscription;

import uim.platform.service;
import uim.platform.appevents.presentation.web.models.event_subscription;
import std.conv      : to;
import std.array     : array;
import std.algorithm : map;

@safe:

class WebEventSubscriptionView {
    Json renderList(WebEventSubscriptionModel model) {
        if (model.errorMessage.length > 0)
            return Json.emptyObject.set("error", model.errorMessage).set("title", model.title);
        return Json.emptyObject
            .set("title", model.title)
            .set("count", model.items.length)
            .set("items", model.items.map!(e => e.toJson()).array.toJson);
    }

    Json renderDetail(WebEventSubscriptionModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("error", model.errorMessage).set("title", model.title);
        return model.selected.toJson()
            .set("title", model.title);
    }

    Json renderError(string msg)   { return Json.emptyObject.set("error", msg); }
    Json renderSuccess(string msg) { return Json.emptyObject.set("message", msg).set("status", "success"); }
}
