/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.change_log;

// import uim.platform.master_data_integration.application.usecases.query_change_log;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.change_log_entry;
// import uim.platform.master_data_integration.domain.types;
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

  protected void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ChangeLogQueryRequest r;
      r.tenantId = tenantId;
      r.objectId = req.params.get("objectId", "");
      r.category = req.params.get("category", "");
      r.deltaToken = req.params.get("deltaToken", "");

      auto sinceStr = req.params.get("since", "");
      if (sinceStr.length > 0) {
        
        try
          r.sinceTimestamp = sinceStr.to!long;
        catch (Exception) {
        }
      }

      auto entries = changeLogs.query(r);

      auto arr = entries.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(entries.length))
        .set("message", "Change log entries retrieved successfully");

      // Provide the last delta token for incremental polling
      if (entries.length > 0)
        resp["nextDeltaToken"] = Json(entries[$ - 1].deltaToken);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto entry = changeLogs.getEntry(id);
      if (entry.isNull) 
        return errorResponse("Change log entry not found", "Not Found", 404);

    auto responseData = entry.toJson;
    return successResponse("Change log entry retrieved successfully", 200, responseData);
  }
}
