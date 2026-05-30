/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.presentation.http.controllers.audit_log;
import uim.platform.marketrates;


mixin(ShowModule!());

@safe:

class AuditLogController : SAPController {
  private ManageAuditLogsUseCase uc;

  this(ManageAuditLogsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/marketrates/auditlogs",   &handleList);
    router.get("/api/v1/marketrates/auditlogs/*", &handleGet);
  }

  private void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto logs     = uc.list(tenantId);

    auto arr = Json.emptyArray;
    foreach (l; logs) arr ~= l.toJson();

    auto j = Json.emptyObject;
    j["data"]  = arr;
    j["count"] = Json(cast(int) logs.length);
    res.writeJsonBody(j, 200);
  }

  private void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto id       = extractIdFromPath(req);
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto entry    = uc.getById(tenantId, AuditLogId(id));

    if (entry.isNull) {
      writeError(res, 404, "Audit log entry not found");
      return;
    }
    res.writeJsonBody(entry.toJson(), 200);
  }
}
