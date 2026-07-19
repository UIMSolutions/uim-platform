/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.database_extension;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;
mixin(ShowModule!());

@safe:

class GuiDatabaseExtensionView {
    Json buildListDescriptor(GuiDatabaseExtensionModel model) {
        auto rows = Json(model.extensions.map!((e) =>
            Json.emptyObject
                .set("id",               e.id.value)
                .set("extensionName",    e.extensionName)
                .set("extensionVersion", e.extensionVersion)
                .set("status",           e.status.to!string)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","extensionName","extensionVersion","status"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiDatabaseExtensionModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto e = model.selected;
        return Json.emptyObject
            .set("widget",           "detail-panel")
            .set("title",            model.windowTitle)
            .set("id",               e.id.value)
            .set("instanceId",       e.instanceId.value)
            .set("extensionName",    e.extensionName)
            .set("extensionVersion", e.extensionVersion)
            .set("schema",           e.schema_)
            .set("status",           e.status.to!string);
    }
}
