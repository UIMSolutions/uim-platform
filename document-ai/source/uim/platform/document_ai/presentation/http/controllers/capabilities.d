/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.capabilities;

import uim.platform.document_ai.application.usecases.get_capabilities;

import uim.platform.document_ai;

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
      auto caps = uc.getById();

      auto exMethods = caps.extractionMethods.map!(method => Json(m)).array;
      auto supFileTypes = caps.supportedFileTypes.map!(f => ftArr ~= Json(f)).array;
      auto fvArr = caps.fieldValueTypes.map!(fv => Json(fv)).array;
      auto fArr = caps.features.map!(feat => Json(feat)).array;

      auto resp = Json.emptyObject
        .set("serviceName", Json(caps.serviceName))
        .set("serviceVersion", Json(caps.serviceVersion))
        .set("extractionMethods", exMethods)
        .set("supportedFileTypes", supFileTypes)
        .set("fieldValueTypes", fvArr)
        .set("features", fArr)
        .set("maxDocumentSizeMb", Json(caps.maxDocumentSizeMb))
        .set("maxPagesPerDocument", Json(caps.maxPagesPerDocument));

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
