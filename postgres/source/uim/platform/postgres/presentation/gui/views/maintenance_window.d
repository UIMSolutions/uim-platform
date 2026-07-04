/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.maintenance_window;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;

mixin(ShowModule!());

@safe:

class GuiMaintenanceWindowView {
    Json buildListDescriptor(GuiMaintenanceWindowModel model) {
        auto rows = Json(model.windows.map!((w) =>
            Json.emptyObject
                .set("id",           w.id.value)
                .set("dayOfWeek",    w.dayOfWeek)
                .set("startHourUtc", w.startHourUtc)
                .set("status",       w.status.to!string)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","dayOfWeek","startHourUtc","status"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiMaintenanceWindowModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto w = model.selected;
        return Json.emptyObject
            .set("widget",                 "detail-panel")
            .set("title",                  model.windowTitle)
            .set("id",                     w.id.value)
            .set("instanceId",             w.instanceId.value)
            .set("dayOfWeek",              w.dayOfWeek)
            .set("startHourUtc",           w.startHourUtc)
            .set("durationHours",          w.durationHours)
            .set("autoMinorVersionUpgrade", w.autoMinorVersionUpgrade)
            .set("status",                 w.status.to!string);
    }
}
