/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.database_user;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;

mixin(ShowModule!());

@safe:

class GuiDatabaseUserView {
    Json buildListDescriptor(GuiDatabaseUserModel model) {
        auto rows = Json(model.users.map!((u) =>
            Json.emptyObject
                .set("id",       u.id.value)
                .set("username", u.username)
                .set("status",   u.status.to!string)
                .set("roles",    u.roles)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","username","status","roles"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiDatabaseUserModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto u = model.selected;
        return Json.emptyObject
            .set("widget",     "detail-panel")
            .set("title",      model.windowTitle)
            .set("id",         u.id.value)
            .set("instanceId", u.instanceId.value)
            .set("username",   u.username)
            .set("roles",      u.roles)
            .set("status",     u.status.to!string);
    }
}
