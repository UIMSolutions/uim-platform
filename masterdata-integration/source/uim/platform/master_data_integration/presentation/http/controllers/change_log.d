/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.change_log;

// import uim.platform.master_data_integration.application.usecases.query_change_log;

import uim.platform.master_data_integration.application.usecases;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class ChangeLogController : HttpController {
  private QueryChangeLogUseCase changeLogs;

  this(QueryChangeLogUseCase changeLogs) {
    this.changeLogs = changeLogs;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/change-log", &handleQuery);
    router.get("/api/v1/change-log/*", &handleGet);
  }

  protected Json queryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    ChangeLogQueryRequest r;
    r.tenantId = tenantId;
    r.objectId = req.params.get("objectId", "");
    r.category = req.params.get("category", "");
    r.deltaToken = req.params.get("deltaToken", "");

    auto sinceStr = req.params.get("since", "");
    if (sinceStr.length > 0) {

      r.sinceTimestamp = sinceStr.to!long;

    }

    auto entries = changeLogs.query(r).map!(e => e.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", entries)
      .set("totalCount", entries.length);

    // Provide the last delta token for incremental polling
    // TODO: Consider adding a "nextDeltaToken" field in the response for clients to use in subsequent requests
    // if (entries.length > 0)
    //   resp["nextDeltaToken"] = Json(entries[$ - 1].deltaToken);

    return successResponse("Change log entries retrieved successfully", 200, resp);
  }

mixin(HandleTemplate!("handleQuery", "queryHandler"));

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ChangeLogEntryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid change log entry ID", "Bad Request", 400);

    auto entry = changeLogs.getEntry(tenantId, id);
    if (entry.isNull)
      return errorResponse("Change log entry not found", "Not Found", 404);

    auto responseData = entry.toJson;
    return successResponse("Change log entry retrieved successfully", 200, responseData);
  }
}
