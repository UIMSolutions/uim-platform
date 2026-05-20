/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.views.event_subscription;

import uim.platform.service;
import uim.platform.appevents.presentation.gui.models.event_subscription;
import std.conv      : to;
import std.array     : array;
import std.algorithm : map;

@safe:

class GuiEventSubscriptionView {
    Json buildListDescriptor(GuiEventSubscriptionModel model) {
        if (model.errorMessage.length > 0)
            return Json.emptyObject.set("type", "error").set("message", model.errorMessage);
        return Json.emptyObject
            .set("type",    "list")
            .set("title",   "Event Subscriptions")
            .set("columns", ["id", "name", "status", "eventType"].toJson)
            .set("rows",    model.items.map!(e => e.toJson()).array.toJson)
            .set("count",   model.items.length);
    }

    Json buildDetailDescriptor(GuiEventSubscriptionModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("type", "error").set("message", model.errorMessage);
        return Json.emptyObject
            .set("type",  "detail")
            .set("title", "Event Subscription: " ~ model.selected.name)
            .set("data",  model.selected.toJson());
    }
}
