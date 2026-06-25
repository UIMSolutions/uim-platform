/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.http.controllers.backup_policy;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class BackupPolicyController : ManageHttpController {
    private ManageBackupPoliciesUseCase backupPolicies;

    this(ManageBackupPoliciesUseCase backupPolicies) {
        this.backupPolicies = backupPolicies;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/postgres/backup-policies", &handleList);
        router.get("/api/v1/postgres/backup-policies/*", &handleGet);
        router.post("/api/v1/postgres/backup-policies", &handleCreate);
        router.put("/api/v1/postgres/backup-policies/*", &handleUpdate);
        router.delete_("/api/v1/postgres/backup-policies/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto items = backupPolicies.listBackupPolicies(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Backup policies retrieved successfully")
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto id = BackupPolicyId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = backupPolicies.getBackupPolicy(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Backup policy not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        BackupPolicyDTO dto;
        dto.backupPolicyId = BackupPolicyId(data.getString("backupPolicyId", ""));
        dto.tenantId = tenantId;
        dto.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
        dto.retentionPeriod = data.getLong("retentionPeriod", 7);
        dto.backupWindow = data.getString("backupWindow", "");
        dto.backupLocation = data.getString("backupLocation", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));
        auto result = backupPolicies.createBackupPolicy(dto);
        if (result.hasError)
            return errorResponse(result.message, 400); 

        return successResponse("Backup policy created successfully", 201, Json.emptyObject.set("id", result.id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        BackupPolicyDTO dto;
        dto.backupPolicyId = BackupPolicyId(precheck.id);
        dto.tenantId = tenantId;
        dto.retentionPeriod = data.getLong("retentionPeriod", 0);
        dto.backupWindow = data.getString("backupWindow", "");
        dto.backupLocation = data.getString("backupLocation", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));
        auto result = backupPolicies.updateBackupPolicy(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        return successResponse("Backup policy updated successfully", 200, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;
            
        auto tenantId = precheck.tenantId;
        auto id = BackupPolicyId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);

        auto result = backupPolicies.deleteBackupPolicy(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);
        return successResponse("Backup policy deleted successfully", 200, Json.emptyObject.set("id", result.id));
    }
}
