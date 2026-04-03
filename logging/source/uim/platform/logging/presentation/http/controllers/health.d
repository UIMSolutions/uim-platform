/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.health;

import uim.platform.logging;

class HealthController : SAPController {
  this() {
    super();
  }

  this(string serviceName) {
    super();
    this.serviceName = serviceName;
  }

  protected string _serviceName = "logging";
  @property string serviceName() {
    return _serviceName;
  }

  @property void serviceName(string name) {
    _serviceName = name;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/health", &handleHealth);
  }

  private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto j = Json.emptyObject;
    j["status"] = Json("UP");
    j["service"] = Json(serviceName);
    res.writeJsonBody(j, 200);
  }
}
