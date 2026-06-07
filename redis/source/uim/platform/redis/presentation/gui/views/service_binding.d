/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.service_binding;

import uim.platform.redis;


// mixin(ShowModule!());

@safe:

class GuiServiceBindingView {
    Json buildListDescriptor(GuiServiceBindingModel model) {
        auto rows = model.bindings.map!((b) =>
            Json.emptyObject.set("id", b.id.value).set("name", b.name).set("instanceId", b.instanceId.value)
                .set("appId", b.appId).set("status", b.status.to!string).set("expiresAt", b.expiresAt)
        ).array.toJson;
        return Json.emptyObject.set("widget","data-table").set("title", model.windowTitle)
            .set("columns", Json(["id","name","instanceId","appId","status","expiresAt"]))
            .set("rows", rows).set("error", model.errorMessage).set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiServiceBindingModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget","error-panel").set("message", model.errorMessage);
        auto b = model.selected;
        return Json.emptyObject.set("widget","detail-panel").set("title","Binding: " ~ b.name)
            .set("id", b.id.value).set("name", b.name).set("instanceId", b.instanceId.value)
            .set("appId", b.appId).set("status", b.status.to!string).set("expiresAt", b.expiresAt);
    }
}
