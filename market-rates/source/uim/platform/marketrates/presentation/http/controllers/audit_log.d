/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.presentation.http.controllers.audit_log;

import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

class AuditLogController : ManageHttpController {
  private ManageAuditLogsUseCase uc;

  this(ManageAuditLogsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/marketrates/auditlogs",   &handleList);
    router.get("/api/v1/marketrates/auditlogs/*", &handleGet);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck; // Return error response from precheck

    auto tenantId = precheck.tenantId;
    auto logs     = uc.listLogs(tenantId).map!(l => l.toJson()).array.toJson;

    auto responseData = Json.emptyObject
    .set("data", logs)
    .set("count", logs.length);
    return successResponse("Audit log list retrieved successfully", "OK", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck; // Return error response from precheck

    auto id       = AuditLogId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid audit log ID", 400);

    auto tenantId = precheck.tenantId;
    auto entry    = uc.getLog(tenantId, id);

    if (entry.isNull)
      return errorResponse("Audit log entry not found", 404);

    return successResponse("Audit log entry retrieved successfully", "OK", 200, entry.toJson());
  }

}
