/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.scaling_history;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ScalingHistoryController : ManageController {
  private ManageScalingHistoryUseCase usecase;

  this(ManageScalingHistoryUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/apps/*/scaling-history", &handleListByApp);
    router.get("/api/v1/scaling-history/*", &handleGet);
  }

  // GET /api/v1/apps/{appId}/scaling-history
  protected Json listByAppHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto appId = AppId(precheck.id);
    long since = 0;
    foreach (kv; req.query.byKeyValue()) {
      if (kv.key == "since") {
        

        try {
          since = kv.value.to!long;
        } catch (Exception) {
        }
        break;
      }
    }
    auto events = since > 0
      ? usecase.getHistorySince(appId, since) : usecase.getHistory(appId);
    auto arr = events.map!(e => e.toJson()).array.toJson;

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Scaling event list retrieved successfully", "Retrieved", 200, responseData);
  }

  protected void handleListByApp(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listByAppHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/scaling-history/{id}
  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScalingHistoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid scaling event ID", 400);

    auto event = usecase.getEvent(tenantId, id);
    if (event.isNull)
      return errorResponse("Scaling event not found", 404);

    auto responseData = event.toJson();
    return successResponse("Scaling event retrieved successfully", "Retrieved", 200, responseData);
  }
}
