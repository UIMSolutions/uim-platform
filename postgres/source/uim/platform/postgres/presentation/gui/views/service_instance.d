/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.service_instance;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;

// mixin(ShowModule!());

@safe:

class GuiServiceInstanceView {
    Json buildListDescriptor(GuiServiceInstanceModel model) {
        auto rows = Json(model.instances.map!((i) =>
            Json.emptyObject
                .set("id",          i.id.value)
                .set("name",        i.name)
                .set("status",      i.status.to!string)
                .set("hyperscaler", i.hyperscaler.to!string)
                .set("region",      i.region)
                .set("memoryGb",    i.memoryGb)
                .set("multiAz",     i.multiAz)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","name","status","hyperscaler","region","memoryGb","multiAz"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiServiceInstanceModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto i = model.selected;
        return Json.emptyObject
            .set("widget",        "detail-panel")
            .set("title",         model.windowTitle)
            .set("id",            i.id.value)
            .set("name",          i.name)
            .set("status",        i.status.to!string)
            .set("hyperscaler",   i.hyperscaler.to!string)
            .set("region",        i.region)
            .set("engineVersion", i.engineVersion.to!string)
            .set("memoryGb",      i.memoryGb)
            .set("storageGb",     i.storageGb)
            .set("sslEnabled",    i.sslEnabled)
            .set("multiAz",       i.multiAz);
    }
}
