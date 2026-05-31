/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.audit_log;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class AuditLogController : ManageController {
    private ManageAuditLogsUseCase auditLogs;

    this(ManageAuditLogsUseCase auditLogs) {
        this.auditLogs = auditLogs;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/audit-logs", &handleList);
        router.get("/api/v1/customer-identity/audit-logs/*", &handleGet);
        router.post("/api/v1/customer-identity/audit-logs", &handleCreate);
        router.delete_("/api/v1/customer-identity/audit-logs/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = auditLogs.listAuditLogs(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Audit logs retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        AuditLogDTO dto;
        dto.tenantId = tenantId;
        dto.actorId = data.getString("actorId");
        dto.action = data.getString("action");
        dto.resourceType = data.getString("resourceType");
        dto.resourceId = data.getString("resourceId");
        dto.ipAddress = data.getString("ipAddress");
        dto.userAgent = data.getString("userAgent");
        dto.details = data.getString("details");
        dto.success = data.getBoolean("success");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = auditLogs.recordAuditEvent(dto);
        if (result.success)
            return successResponse("Audit event recorded successfully", "Created", 201, Json.emptyObject.set("id", result
                    .id));
        return errorResponse(result.message, 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = AuditLogId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Audit Log ID", 400);

        auto e = auditLogs.getAuditLog(tenantId, id);
        if (e.isNull)
            return errorResponse("Audit log not found", 404);

        return successResponse("Audit log retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = AuditLogId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Audit Log ID", 400);

        auto result = auditLogs.deleteAuditLog(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        return successResponse("Audit log deleted successfully", "Deleted", 200, Json.emptyObject);
    }
}
