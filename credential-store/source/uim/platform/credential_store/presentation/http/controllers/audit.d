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
  private GetAuditLogsUseCase uc;

  this(GetAuditLogsUseCase uc) {
    this.uc = uc;
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
        entries = uc.listByNamespace(tenantId, namespaceId);
      } else if (resourceType.length > 0) {
        entries = uc.listByResourceType(tenantId, resourceType);
      } else {
        entries = uc.list(tenantId);
      }

      auto jarr = Json.emptyArray;
      foreach (ref e; entries) {
        auto ej = Json.emptyObject;
        ej["id"] = Json(e.id);
        ej["namespaceId"] = Json(e.namespaceId);
        ej["resourceName"] = Json(e.resourceName);
        ej["performedBy"] = Json(e.performedBy);
        ej["timestamp"] = Json(e.timestamp);
        ej["details"] = Json(e.details);
        ej["success"] = Json(e.success);
        jarr ~= ej;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) entries.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto e = uc.getById(id);

      if (e.id.isEmpty) {
        writeError(res, 404, "Audit log entry not found");
        return;
      }

      auto ej = Json.emptyObject;
      ej["id"] = Json(e.id);
      ej["tenantId"] = Json(e.tenantId);
      ej["namespaceId"] = Json(e.namespaceId);
      ej["resourceName"] = Json(e.resourceName);
      ej["performedBy"] = Json(e.performedBy);
      ej["timestamp"] = Json(e.timestamp);
      ej["details"] = Json(e.details);
      ej["sourceIp"] = Json(e.sourceIp);
      ej["success"] = Json(e.success);
      res.writeJsonBody(ej, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
