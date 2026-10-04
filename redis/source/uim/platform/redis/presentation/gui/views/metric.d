/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.metric;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class GuiMetricView {
    Json buildListDescriptor(GuiMetricModel model) {
        auto rows = model.metrics.map!((m) =>
            Json.emptyObject.set("id", m.id.value).set("timestamp", m.timestamp_)
                .set("memUsed", m.memoryUsedMb).set("clients", m.connectedClients).set("hitRate", m.hitRate)
        ).array.toJson;
        return Json.emptyObject.set("widget","data-table").set("title", model.windowTitle)
            .set("columns", Json(["id","timestamp","memUsed","clients","hitRate"]))
            .set("rows", rows).set("error", model.errorMessage).set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiMetricModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget","error-panel").set("message", model.errorMessage);
        auto m = model.selected;
        return Json.emptyObject.set("widget","detail-panel").set("title","Metric: " ~ m.id.value)
            .set("id", m.id.value).set("timestamp", m.timestamp_).set("memoryUsedMb", m.memoryUsedMb)
            .set("memoryTotalMb", m.memoryTotalMb).set("connectedClients", m.connectedClients)
            .set("commandsPerSecond", m.commandsPerSecond).set("hitRate", m.hitRate)
            .set("evictedKeys", m.evictedKeys).set("expiredKeys", m.expiredKeys);
    }
}
