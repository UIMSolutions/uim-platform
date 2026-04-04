/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.capabilities;

import uim.platform.document_ai.application.usecases.get_capabilities;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class CapabilitiesController : SAPController {
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
      auto caps = uc.get_();

      auto resp = Json.emptyObject;
      resp["serviceName"] = Json(caps.serviceName);
      resp["serviceVersion"] = Json(caps.serviceVersion);

      auto extArr = Json.emptyArray;
      foreach (ref m; caps.extractionMethods) {
        extArr ~= Json(m);
      }
      resp["extractionMethods"] = extArr;

      auto ftArr = Json.emptyArray;
      foreach (ref f; caps.supportedFileTypes) {
        ftArr ~= Json(f);
      }
      resp["supportedFileTypes"] = ftArr;

      auto fvArr = Json.emptyArray;
      foreach (ref fv; caps.fieldValueTypes) {
        fvArr ~= Json(fv);
      }
      resp["fieldValueTypes"] = fvArr;

      auto fArr = Json.emptyArray;
      foreach (ref feat; caps.features) {
        fArr ~= Json(feat);
      }
      resp["features"] = fArr;

      resp["maxDocumentSizeMb"] = Json(cast(long) caps.maxDocumentSizeMb);
      resp["maxPagesPerDocument"] = Json(cast(long) caps.maxPagesPerDocument);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
