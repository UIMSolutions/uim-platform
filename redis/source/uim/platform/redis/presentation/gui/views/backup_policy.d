/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.views.backup_policy;

import uim.platform.redis;
import std.conv : to;

mixin(ShowModule!());

@safe:

class GuiBackupPolicyView {
    Json buildListDescriptor(GuiBackupPolicyModel model) {
        auto rows = model.policies.map!((p) =>
            Json.emptyObject.set("id", p.id.value).set("intervalHours", p.intervalHours)
                .set("retentionDays", p.retentionDays).set("status", p.status.to!string).set("enabled", p.enabled)
        ).array.toJson;
        return Json.emptyObject.set("widget","data-table").set("title", model.windowTitle)
            .set("columns", Json(["id","intervalHours","retentionDays","status","enabled"]))
            .set("rows", rows).set("error", model.errorMessage).set("success", model.successMessage);
    }

    Json buildDetailDescriptor(GuiBackupPolicyModel model) {
        if (!model.hasSelected)
            return Json.emptyObject.set("widget","error-panel").set("message", model.errorMessage);
        auto p = model.selected;
        return Json.emptyObject.set("widget","detail-panel").set("title","Policy: " ~ p.id.value)
            .set("id", p.id.value).set("intervalHours", p.intervalHours).set("retentionDays", p.retentionDays)
            .set("backupLocation", p.backupLocation).set("status", p.status.to!string).set("enabled", p.enabled);
    }
}
