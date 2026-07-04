/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.service_plan;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;

mixin(ShowModule!());

@safe:

class GuiServicePlanView {
    Json buildListDescriptor(GuiServicePlanModel model) {
        auto rows = Json(model.plans.map!((p) =>
            Json.emptyObject
                .set("id",        p.id.value)
                .set("name",      p.name)
                .set("tier",      p.tier.to!string)
                .set("memoryGb",  p.memoryGb)
                .set("storageGb", p.storageGb)
                .set("available", p.available)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","name","tier","memoryGb","storageGb","available"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiServicePlanModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto p = model.selected;
        return Json.emptyObject
            .set("widget",          "detail-panel")
            .set("title",           model.windowTitle)
            .set("id",              p.id.value)
            .set("name",            p.name)
            .set("tier",            p.tier.to!string)
            .set("memoryGb",        p.memoryGb)
            .set("storageGb",       p.storageGb)
            .set("maxConnections",  p.maxConnections)
            .set("multiAzSupported", p.multiAzSupported)
            .set("available",       p.available);
    }
}
