/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.presentation.http.controllers.audit_log;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

class AuditLogController : ManageHttpController {
  protected ManageAuditLogsUseCase uc;

  this(ManageAuditLogsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/market_refinitiv/auditlogs", &handleList);
    router.get("/api/v1/market_refinitiv/auditlogs/*", &handleGet);
  }

  override Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) 
      return precheck;

    auto tenantId = precheck.tenantId;
    auto logs = uc.list(tenantId);
    auto jsonLogs = logs.map!toJson.array.toJson();

    auto j = Json.emptyObject
      .set("data", jsonLogs)
      .set("count", jsonLogs.length);

    return j;
  }

  override Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) 
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AuditLogId(precheck.id);
    auto entry = uc.getById(tenantId, id);

    if (entry.isNull) {
      return Json.emptyObject.set("error", "Audit log entry not found");
    }

    return entry.toJson();
  }

}