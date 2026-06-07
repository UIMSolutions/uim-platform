/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.health;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
class HealthController : SAPController {
  private string serviceName;

  this(string serviceName) {
    this.serviceName = serviceName;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/health", &handleHealth);
  }

  private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto resp = Json.emptyObject
      .set("status", "UP")
      .set("service", serviceName);
    res.writeJsonBody(resp, 200);
  }
}
