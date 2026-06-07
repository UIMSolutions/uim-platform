/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.health;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;

// mixin(ShowModule!());

@safe:
class HealthController : SAPController {
  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/health", &handleHealth);
  }

  void handleHealth(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = Json.emptyObject;
    j["status"]  = Json("ok");
    j["service"] = Json("Datasphere Data Composer");
    j["version"] = Json("1.0.0");
    res.writeJsonBody(j, cast(int) HTTPStatus.ok);
  }
}
