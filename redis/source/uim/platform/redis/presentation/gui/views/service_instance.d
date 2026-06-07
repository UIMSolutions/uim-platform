/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.service_instance;

import uim.platform.redis;
import std.conv   : to;
import std.format : format;

// mixin(ShowModule!());

@safe:

/// GUI View scaffold — renders ServiceInstance state as a widget descriptor tree.
/// Actual widget rendering is toolkit-specific; this emits a Json descriptor
/// that a frontend renderer can consume.
class GuiServiceInstanceView {
    /// Build a list-panel descriptor.
    Json buildListDescriptor(GuiServiceInstanceModel model) {
        auto rows = model.instances.map!((i) =>
            Json.emptyObject
                .set("id",     i.id.value)
                .set("name",   i.name)
                .set("status", i.status.to!string)
                .set("region", i.region)
                .set("memory", i.memoryMb)
                .set("ha",     i.haEnabled)
        ).array.toJson;

        return Json.emptyObject
            .set("widget",       "data-table")
            .set("title",        model.windowTitle)
            .set("columns",      Json(["id","name","status","region","memory","ha"]))
            .set("rows",         rows)
            .set("error",        model.errorMessage)
            .set("success",      model.successMessage);
    }

    /// Build a detail-panel descriptor.
    Json buildDetailDescriptor(GuiServiceInstanceModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget", "error-panel").set("message", model.errorMessage);

        auto i = model.selected;
        return Json.emptyObject
            .set("widget",          "detail-panel")
            .set("title",           "Instance: " ~ i.name)
            .set("id",              i.id.value)
            .set("name",            i.name)
            .set("status",          i.status.to!string)
            .set("hyperscaler",     i.hyperscaler.to!string)
            .set("region",          i.region)
            .set("redisVersion",    i.redisVersion.to!string)
            .set("memoryMb",        i.memoryMb)
            .set("maxConnections",  i.maxConnections)
            .set("tlsEnabled",      i.tlsEnabled)
            .set("haEnabled",       i.haEnabled)
            .set("persistenceMode", i.persistenceMode.to!string);
    }

    /// Build a form descriptor for creating an instance.
    Json buildCreateFormDescriptor() {
        return Json.emptyObject
            .set("widget", "form")
            .set("title",  "Create Service Instance")
            .set("fields", Json([
                Json.emptyObject.set("name","name").set("type","text").set("label","Name").set("required", true),
                Json.emptyObject.set("name","planId").set("type","text").set("label","Plan ID").set("required", true),
                Json.emptyObject.set("name","region").set("type","text").set("label","Region"),
                Json.emptyObject.set("name","memoryMb").set("type","number").set("label","Memory MB").set("default", 256),
                Json.emptyObject.set("name","tlsEnabled").set("type","checkbox").set("label","TLS").set("default", true),
                Json.emptyObject.set("name","haEnabled").set("type","checkbox").set("label","High Availability").set("default", false)
            ]));
    }
}
