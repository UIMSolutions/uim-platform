/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.backup_policy;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class BackupPolicyController : ManageHttpController {
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
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = backupPolicies.listBackupPolicies(tenantId);
        return successResponse("Backup policies retrieved successfully", "Retrieved", 200, Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BackupPolicyId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid backup policy ID", 400);

        auto e = backupPolicies.getBackupPolicy(tenantId, id);
        if (e.isNull)
            return errorResponse("Backup policy not found", 404);

        return successResponse("Backup policy retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        BackupPolicyDTO dto;
        dto.backupPolicyId  = BackupPolicyId(data.getString("backupPolicyId", ""));
        dto.tenantId        = tenantId;
        dto.instanceId      = ServiceInstanceId(data.getString("instanceId", ""));
        dto.enabled         = data.getBoolean("enabled", true);
        dto.intervalHours   = data.getLong("intervalHours", 24);
        dto.retentionDays   = data.getLong("retentionDays", 7);
        dto.backupLocation  = data.getString("backupLocation", "");
        dto.createdBy       = UserId(data.getString("createdBy", ""));

        auto result = backupPolicies.createBackupPolicy(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Backup policy created successfully", "Created", 201, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        BackupPolicyDTO dto;
        dto.backupPolicyId  = BackupPolicyId(precheck.id);
        dto.tenantId        = tenantId;
        dto.enabled         = data.getBoolean("enabled", true);
        dto.intervalHours   = data.getLong("intervalHours", 0);
        dto.retentionDays   = data.getLong("retentionDays", 0);
        dto.backupLocation  = data.getString("backupLocation", "");
        dto.updatedBy       = UserId(data.getString("updatedBy", ""));

        auto result = backupPolicies.updateBackupPolicy(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Backup policy updated successfully", "Updated", 200, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BackupPolicyId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid backup policy ID", 400);

        auto result = backupPolicies.deleteBackupPolicy(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Backup policy deleted successfully", "Deleted", 200, Json.emptyObject
            .set("id", result.id));
    }
}
