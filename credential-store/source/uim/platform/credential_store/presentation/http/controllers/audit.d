/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.audit;

// import uim.platform.credential_store.application.usecases.get_audit_logs;
// import uim.platform.credential_store.application.dto;
// import uim.platform.credential_store.domain.entities.audit_log_entry;
// import uim.platform.credential_store.domain.types;
// import uim.platform.credential_store.presentation.http.json_utils;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class AuditController : PlatformController {
  private GetAuditLogsUseCase auditLogs;

  this(GetAuditLogsUseCase auditLogs) {
    this.auditLogs = auditLogs;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/audit-logs", &handleList);
    router.get("/api/v1/audit-logs/*", &handleGetById);
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      TenantId tenantId = req.getTenantId;
      auto namespaceId = req.params.get("namespaceId", "");
      auto resourceType = req.params.get("resourceType", "");

      AuditLogEntry[] entries;
      if (namespaceId.length > 0) {
        entries = auditLogs.listByNamespace(tenantId, NamespaceId(namespaceId));
      } else if (resourceType.length > 0) {
        entries = auditLogs.listByResourceType(tenantId, resourceType);
      } else {
        entries = auditLogs.list(tenantId);
      }

      auto jarr = Json.emptyArray;
      foreach (auditLog; entries) {
        jarr ~= Json.emptyObject
          .set("id", auditLog.id)
          .set("namespaceId", auditLog.namespaceId)
          .set("resourceName", auditLog.resourceName)
          .set("performedBy", auditLog.performedBy)
          .set("timestamp", auditLog.timestamp)
          .set("details", auditLog.details)
          .set("success", auditLog.success);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", entries.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = AuditLogEntryId(extractIdFromPath(req.requestURI.to!string));
      auto auditLog = auditLogs.getById(id);

      if (auditLog.isNull) {
        writeError(res, 404, "Audit log entry not found");
        return;
      }

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

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
