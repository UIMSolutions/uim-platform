/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.audit;
// import uim.platform.credential_store.application.usecases.get_audit_logs;
// import uim.platform.credential_store.application.dto;
// import uim.platform.credential_store.domain.entities.audit_log_entry;


import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:
class AuditController : HttpController {
  private GetAuditLogsUseCase auditLogs;

  this(GetAuditLogsUseCase auditLogs) {
    this.auditLogs = auditLogs;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/audit-logs", &handleList);
    router.get("/api/v1/audit-logs/*", &handleGet);
  }

  protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto namespaceId = NamespaceId(req.params.get("namespaceId", ""));
    auto resourceType = req.params.get("resourceType", "");

    AuditLogEntry[] entries;
    if (!namespaceId.isNull) {
      entries = auditLogs.listLogs(tenantId, namespaceId);
    } else if (!resourceType.isEmpty) {
      entries = auditLogs.listLogs(tenantId, resourceType);
    } else {
      entries = auditLogs.listLogs(tenantId);
    }

    auto list = Json.emptyArray;
    foreach (auditLog; entries) {
      list ~= Json.emptyObject
        .set("id", auditLog.id)
        .set("namespaceId", auditLog.namespaceId)
        .set("resourceName", auditLog.resourceName)
        .set("performedBy", auditLog.performedBy)
        .set("timestamp", auditLog.timestamp)
        .set("details", auditLog.details)
        .set("success", auditLog.success);
    }

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Audit logs retrieved successfully", "Retrieved", 200, responseData);
  }

  mixin(HandleTemplate!("handleList", "listHandler"));

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AuditLogEntryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid audit log ID", 400);

    auto auditLog = auditLogs.getLog(tenantId, id);
    if (auditLog.isNull)
      return errorResponse("Audit log entry not found", 404);

    auto response = Json.emptyObject
      .set("id", auditLog.id)
      .set("tenantId", auditLog.tenantId)
      .set("namespaceId", auditLog.namespaceId)
      .set("resourceName", auditLog.resourceName)
      .set("performedBy", auditLog.performedBy)
      .set("timestamp", auditLog.timestamp)
      .set("details", auditLog.details)
      .set("sourceIp", auditLog.sourceIp)
      .set("success", auditLog.success);

    return successResponse("Audit log entry retrieved successfully", "Retrieved", 200, response);
  }
}
