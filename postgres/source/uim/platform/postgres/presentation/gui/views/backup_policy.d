/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.views.backup_policy;

import uim.platform.postgres;
import std.conv      : to;
import std.algorithm : map;
import std.array     : array;

// mixin(ShowModule!());

@safe:

class GuiBackupPolicyView {
    Json buildListDescriptor(GuiBackupPolicyModel model) {
        auto rows = Json(model.policies.map!((p) =>
            Json.emptyObject
                .set("id",              p.id.value)
                .set("instanceId",      p.instanceId.value)
                .set("retentionPeriod", p.retentionPeriod)
                .set("status",          p.status.to!string)
        ).array);
        return Json.emptyObject
            .set("widget",  "data-table")
            .set("title",   model.windowTitle)
            .set("columns", Json(["id","instanceId","retentionPeriod","status"]))
            .set("rows",    rows)
            .set("error",   model.errorMessage)
            .set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiBackupPolicyModel model) {
        if (!model.hasSelected) return Json.emptyObject.set("error", model.errorMessage);
        auto p = model.selected;
        return Json.emptyObject
            .set("widget",          "detail-panel")
            .set("title",           model.windowTitle)
            .set("id",              p.id.value)
            .set("instanceId",      p.instanceId.value)
            .set("retentionPeriod", p.retentionPeriod)
            .set("backupWindow",    p.backupWindow)
            .set("status",          p.status.to!string)
            .set("backupLocation",  p.backupLocation);
    }
}
