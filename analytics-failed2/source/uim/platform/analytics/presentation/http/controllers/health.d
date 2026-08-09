/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.presentation.http.controllers.health;

import vibe.data.json : Json;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class AnalyticsHealthController {
  void registerRoutes(URLRouter router) {
    router.get("/api/v1/health", &handleHealth);
  }

  private void handleHealth(HTTPServerRequest req, HTTPServerResponse res) {
    auto payload = Json.emptyObject;
    payload["status"] = Json("UP");
    payload["service"] = Json("Analytics");
    res.writeJsonBody(payload, 200);
  }
}
