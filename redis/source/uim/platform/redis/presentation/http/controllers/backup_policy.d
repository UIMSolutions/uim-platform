/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.backup_policy;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class BackupPolicyController : ManageController {
    private ManageBackupPoliciesUseCase backupPolicies;

    this(ManageBackupPoliciesUseCase backupPolicies) {
        this.backupPolicies = backupPolicies;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/backup-policies",   &handleList);
        router.get("/api/v1/redis/backup-policies/*", &handleGet);
        router.post("/api/v1/redis/backup-policies",  &handleCreate);
        router.put("/api/v1/redis/backup-policies/*", &handleUpdate);
        router.delete_("/api/v1/redis/backup-policies/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto items = backupPolicies.listBackupPolicies(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Backup policies retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto id = BackupPolicyId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid backup policy ID").set("statusCode", 400);

        auto e = backupPolicies.getBackupPolicy(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Backup policy not found").set("statusCode", 404);

        return e.toJson().set("message", "Backup policy retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;

        BackupPolicyDTO dto;
        dto.backupPolicyId  = BackupPolicyId(data.getString("backupPolicyId", ""));
        dto.tenantId        = tenantId;
        dto.instanceId      = ServiceInstanceId(data.getString("instanceId", ""));
        dto.enabled         = data.getBool("enabled", true);
        dto.intervalHours   = data.getLong("intervalHours", 24);
        dto.retentionDays   = data.getLong("retentionDays", 7);
        dto.backupLocation  = data.getString("backupLocation", "");
        dto.createdBy       = UserId(data.getString("createdBy", ""));

        auto result = backupPolicies.createBackupPolicy(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Backup policy created successfully")
            .set("status", "success")
            .set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;

        BackupPolicyDTO dto;
        dto.backupPolicyId  = BackupPolicyId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId        = tenantId;
        dto.enabled         = data.getBool("enabled", true);
        dto.intervalHours   = data.getLong("intervalHours", 0);
        dto.retentionDays   = data.getLong("retentionDays", 0);
        dto.backupLocation  = data.getString("backupLocation", "");
        dto.updatedBy       = UserId(data.getString("updatedBy", ""));

        auto result = backupPolicies.updateBackupPolicy(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Backup policy updated successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto id = BackupPolicyId(extractIdFromPath(req.requestURI.to!string));

        auto result = backupPolicies.deleteBackupPolicy(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Backup policy deleted successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
