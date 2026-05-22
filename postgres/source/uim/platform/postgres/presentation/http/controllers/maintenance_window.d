/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.http.controllers.maintenance_window;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class MaintenanceWindowController : ManageController {
    private ManageMaintenanceWindowsUseCase maintenanceWindows;

    this(ManageMaintenanceWindowsUseCase maintenanceWindows) { this.maintenanceWindows = maintenanceWindows; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/postgres/maintenance-windows",        &handleList);
        router.get("/api/v1/postgres/maintenance-windows/*",      &handleGet);
        router.post("/api/v1/postgres/maintenance-windows",       &handleCreate);
        router.put("/api/v1/postgres/maintenance-windows/*",      &handleUpdate);
        router.delete_("/api/v1/postgres/maintenance-windows/*",  &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto items = maintenanceWindows.listMaintenanceWindows(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Maintenance windows retrieved successfully")
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = MaintenanceWindowId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = maintenanceWindows.getMaintenanceWindow(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Maintenance window not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        MaintenanceWindowDTO dto;
        dto.maintenanceWindowId       = MaintenanceWindowId(data.getString("maintenanceWindowId", ""));
        dto.tenantId                  = tenantId;
        dto.instanceId                = ServiceInstanceId(data.getString("instanceId", ""));
        dto.dayOfWeek                 = data.getString("dayOfWeek", "Sunday");
        dto.startHourUtc              = data.getLong("startHourUtc", 2);
        dto.durationHours             = data.getLong("durationHours", 1);
        dto.autoMinorVersionUpgrade   = data.getBool("autoMinorVersionUpgrade", true);
        dto.createdBy                 = UserId(data.getString("createdBy", ""));
        auto result = maintenanceWindows.createMaintenanceWindow(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Maintenance window created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        MaintenanceWindowDTO dto;
        dto.maintenanceWindowId     = MaintenanceWindowId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId                = tenantId;
        dto.dayOfWeek               = data.getString("dayOfWeek", "");
        dto.startHourUtc            = data.getLong("startHourUtc", -1);
        dto.durationHours           = data.getLong("durationHours", 0);
        dto.autoMinorVersionUpgrade = data.getBool("autoMinorVersionUpgrade", true);
        dto.updatedBy               = UserId(data.getString("updatedBy", ""));
        auto result = maintenanceWindows.updateMaintenanceWindow(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Maintenance window updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = MaintenanceWindowId(extractIdFromPath(req.requestURI.to!string));
        auto result = maintenanceWindows.deleteMaintenanceWindow(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Maintenance window deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
