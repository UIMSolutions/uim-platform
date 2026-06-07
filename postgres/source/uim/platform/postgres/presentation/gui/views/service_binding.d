/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.service_binding;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;

// mixin(ShowModule!());

@safe:

class GuiServiceBindingView {
    Json buildListDescriptor(GuiServiceBindingModel model) {
        auto rows = Json(model.bindings.map!((b) =>
            Json.emptyObject
                .set("id",     b.id.value)
                .set("name",   b.name)
                .set("status", b.status.to!string)
                .set("appId",  b.appId)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","name","status","appId"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiServiceBindingModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto b = model.selected;
        return Json.emptyObject
            .set("widget",      "detail-panel")
            .set("title",       model.windowTitle)
            .set("id",          b.id.value)
            .set("name",        b.name)
            .set("status",      b.status.to!string)
            .set("instanceId",  b.instanceId.value)
            .set("appId",       b.appId)
            .set("host",        b.bindingHost)
            .set("port",        b.bindingPort)
            .set("database",    b.database)
            .set("sslMode",     b.sslMode.to!string);
    }
}
