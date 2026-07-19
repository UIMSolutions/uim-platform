/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.configuration;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;
mixin(ShowModule!());

@safe:

class GuiConfigurationView {
    Json buildListDescriptor(GuiConfigurationModel model) {
        auto rows = Json(model.configurations.map!((c) =>
            Json.emptyObject
                .set("id",             c.id.value)
                .set("instanceId",     c.instanceId.value)
                .set("locale",         c.locale)
                .set("maxConnections", c.maxConnections)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","instanceId","locale","maxConnections"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiConfigurationModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto c = model.selected;
        return Json.emptyObject
            .set("widget",               "detail-panel")
            .set("title",                model.windowTitle)
            .set("id",                   c.id.value)
            .set("instanceId",           c.instanceId.value)
            .set("locale",               c.locale)
            .set("maxConnections",       c.maxConnections)
            .set("workMem",              c.workMem)
            .set("sharedBuffersMb",      c.sharedBuffersMb)
            .set("backupRetentionPeriod", c.backupRetentionPeriod);
    }
}
