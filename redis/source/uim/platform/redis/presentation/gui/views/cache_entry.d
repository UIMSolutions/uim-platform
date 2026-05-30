/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.cache_entry;

import uim.platform.redis;


mixin(ShowModule!());

@safe:

class GuiCacheEntryView {
    Json buildListDescriptor(GuiCacheEntryModel model) {
        auto rows = model.entries.map!((e) =>
            Json.emptyObject.set("id", e.id.value).set("key", e.key).set("type", e.entryType.to!string)
                .set("ttl", e.ttl)
        ).array.toJson;
        return Json.emptyObject.set("widget","data-table").set("title", model.windowTitle)
            .set("columns", Json(["id","key","type","ttl"]))
            .set("rows", rows).set("error", model.errorMessage).set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiCacheEntryModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget","error-panel").set("message", model.errorMessage);
        auto e = model.selected;
        string v = e.value.length > 512 ? e.value[0..512] ~ "..." : e.value;
        return Json.emptyObject.set("widget","detail-panel").set("title","Key: " ~ e.key)
            .set("id", e.id.value).set("key", e.key).set("type", e.entryType.to!string)
            .set("ttl", e.ttl).set("value", v);
    }
}
