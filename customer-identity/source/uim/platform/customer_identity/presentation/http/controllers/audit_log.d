/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.audit_log;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class AuditLogController : PlatformController {
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
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantIf(precheck.gString("tenantId"));
        auto items = auditLogs.listAuditLogs(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantIf(precheck.gString("tenantId"));
        auto j = req.json;

        AuditLogDTO dto;
        dto.tenantId = tenantId;
        dto.actorId = j.getString("actorId");
        dto.action = j.getString("action");
        dto.resourceType = j.getString("resourceType");
        dto.resourceId = j.getString("resourceId");
        dto.ipAddress = j.getString("ipAddress");
        dto.userAgent = j.getString("userAgent");
        dto.details = j.getString("details");
        dto.success = j.getBool("success");
        dto.createdBy = UserId(j.getString("createdBy"));

        auto result = auditLogs.recordAuditEvent(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Audit event recorded").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantIf(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = AuditLogId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Audit Log ID").set("status", "error").set("statusCode", 400);

        auto e = auditLogs.getAuditLog(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Audit log not found").set("status", "error").set("statusCode", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantIf(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = AuditLogId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Audit Log ID").set("status", "error").set("statusCode", 400);

        auto result = auditLogs.deleteAuditLog(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Audit log deleted").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 404);
    }
}
