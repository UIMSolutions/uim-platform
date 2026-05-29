/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.presentation.http.controllers.health;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

class HealthController : SAPController {

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/health", &handleHealth);
  }

  private void handleHealth(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = Json.emptyObject;
    j["status"]  = Json("UP");
    j["service"] = Json("Market Rates Management - BYOR");
    res.writeJsonBody(j, 200);
  }
}
