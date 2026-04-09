/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.health;

import uim.platform.document_ai;

class HealthController : PlatformController {
  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/health", &handleHealth);
  }

  private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto j = Json.emptyObject;
    j["status"] = Json("UP");
    j["service"] = Json("Document AI Service");
    res.writeJsonBody(j, 200);
  }
}
