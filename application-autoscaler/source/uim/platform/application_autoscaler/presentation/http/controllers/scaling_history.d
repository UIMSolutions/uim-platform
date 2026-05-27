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
    router.get("/api/v1/scaling-history/*",      &handleGet);
  }

  // GET /api/v1/apps/{appId}/scaling-history
  override protected void handleListByApp(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto appId = AppId(extractIdFromPath(req));
      long since = 0;
      foreach (kv; req.query.byKeyValue()) {
        if (kv.key == "since") {
          import std.conv : to;
          try { since = kv.value.to!long; } catch (Exception) {}
          break;
        }
      }
      auto events = since > 0
        ? usecase.getHistorySince(appId, since)
        : usecase.getHistory(appId);
      auto arr = Json.emptyArray;
      foreach (e; events) arr ~= e.toJson();
      res.writeJsonBody(Json.emptyObject.set("items", arr).set("totalCount", events.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/scaling-history/{id}
  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ScalingHistoryId(extractIdFromPath(req));

      auto evt = usecase.getEvent(tenantId, id);
      if (evt.isNull) {
        writeError(res, 404, "Scaling event not found");
        return;
      }
      res.writeJsonBody(evt.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
