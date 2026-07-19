/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.maintenance_window;

import uim.platform.postgres;
mixin(ShowModule!());

@safe:

struct MaintenanceWindow {
    mixin TenantEntity!(MaintenanceWindowId);

    ServiceInstanceId instanceId;
    string dayOfWeek;       // e.g. "Sunday"
    long   startHourUtc;    // 0-23
    long   durationHours;   // 1-8
    bool   autoMinorVersionUpgrade;
    MaintenanceStatus status;
    long lastMaintenanceAt;
    long nextMaintenanceAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id",                      id.value)
            .set("tenantId",                tenantId.value)
            .set("instanceId",              instanceId.value)
            .set("dayOfWeek",               dayOfWeek)
            .set("startHourUtc",            startHourUtc)
            .set("durationHours",           durationHours)
            .set("autoMinorVersionUpgrade", autoMinorVersionUpgrade)
            .set("status",                  status.to!string)
            .set("lastMaintenanceAt",       lastMaintenanceAt)
            .set("nextMaintenanceAt",       nextMaintenanceAt)
            .set("createdAt",               createdAt)
            .set("createdBy",               createdBy.value)
            .set("updatedBy",               updatedBy.value);
    }
}
