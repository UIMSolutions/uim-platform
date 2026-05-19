/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.service_plan;

import uim.platform.redis;
import std.conv : to;

mixin(ShowModule!());

@safe:

class GuiServicePlanView {
    Json buildListDescriptor(GuiServicePlanModel model) {
        auto rows = model.plans.map!((p) =>
            Json.emptyObject.set("id", p.id.value).set("name", p.name).set("tier", p.tier.to!string)
                .set("memoryMb", p.memoryMb).set("ha", p.haEnabled).set("available", p.available)
        ).array.toJson;
        return Json.emptyObject.set("widget","data-table").set("title", model.windowTitle)
            .set("columns", Json(["id","name","tier","memoryMb","ha","available"]))
            .set("rows", rows).set("error", model.errorMessage).set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiServicePlanModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget","error-panel").set("message", model.errorMessage);
        auto p = model.selected;
        return Json.emptyObject.set("widget","detail-panel").set("title","Plan: " ~ p.name)
            .set("id", p.id.value).set("name", p.name).set("tier", p.tier.to!string)
            .set("memoryMb", p.memoryMb).set("maxConnections", p.maxConnections)
            .set("haEnabled", p.haEnabled).set("persistenceEnabled", p.persistenceEnabled)
            .set("tlsEnabled", p.tlsEnabled).set("available", p.available);
    }
}
