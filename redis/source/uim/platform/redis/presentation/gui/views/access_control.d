/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.access_control;

import uim.platform.redis;


mixin(ShowModule!());

@safe:

class GuiAccessControlView {
    Json buildListDescriptor(GuiAccessControlModel model) {
        auto rows = model.rules.map!((a) =>
            Json.emptyObject.set("id", a.id.value).set("cidr", a.cidr)
                .set("description", a.description).set("status", a.status.to!string)
        ).array.toJson;
        return Json.emptyObject.set("widget","data-table").set("title", model.windowTitle)
            .set("columns", Json(["id","cidr","description","status"]))
            .set("rows", rows).set("error", model.errorMessage).set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiAccessControlModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget","error-panel").set("message", model.errorMessage);
        auto a = model.selected;
        return Json.emptyObject.set("widget","detail-panel").set("title","Rule: " ~ a.cidrBlock)
            .set("id", a.id.value).set("cidr", a.cidr).set("description", a.description)
            .set("status", a.status.to!string).set("instanceId", a.instanceId.value);
    }
}
