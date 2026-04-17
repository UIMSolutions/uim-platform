/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.capabilities;

import uim.platform.ai_launchpad.application.usecases.get_capabilities;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class CapabilitiesController : PlatformController {
  private GetCapabilitiesUseCase uc;

  this(GetCapabilitiesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/capabilities", &handleGet);
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto cap = uc.getById();

      auto resp = Json.emptyObject
      .set("serviceName", cap.serviceName)
      .set("serviceVersion", cap.serviceVersion)
      .set("supportedRuntimes", cap.supportedRuntimes)
      .set("features", cap.features)
      .set("multiTenant", cap.multiTenant)
      .set("genAiHub", cap.genAiHub)
      .set("promptManagement", cap.promptManagement)
      .set("usageStatistics", cap.usageStatistics)
      .set("bulkOperations", cap.bulkOperations)
      .set("maxConnections", cap.maxConnections);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
