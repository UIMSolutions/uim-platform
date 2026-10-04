/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.configuration;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class GuiConfigurationView {
    Json buildListDescriptor(GuiConfigurationModel model) {
        auto rows = model.configurations.map!((c) =>
            Json.emptyObject.set("id", c.id.value).set("instanceId", c.instanceId.value)
                .set("eviction", c.maxMemoryPolicy.to!string).set("tls", c.tlsEnabled).set("persistence", c.persistenceMode.to!string)
        ).array.toJson;
        return Json.emptyObject.set("widget","data-table").set("title", model.windowTitle)
            .set("columns", Json(["id","instanceId","eviction","tls","persistence"]))
            .set("rows", rows).set("error", model.errorMessage).set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiConfigurationModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget","error-panel").set("message", model.errorMessage);
        auto c = model.selected;
        return Json.emptyObject.set("widget","detail-panel").set("title","Configuration: " ~ c.id.value)
            .set("id", c.id.value).set("instanceId", c.instanceId.value)
            .set("maxMemoryPolicy", c.maxMemoryPolicy.to!string).set("maxMemoryMb", c.maxMemoryMb)
            .set("timeout", c.timeout).set("tlsEnabled", c.tlsEnabled).set("persistenceMode", c.persistenceMode.to!string)
            .set("notifyKeyspaceEvents", c.notifyKeyspaceEvents);
    }
}
