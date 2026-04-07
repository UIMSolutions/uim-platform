/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.find;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.destination.application.usecases.find_destination;
import uim.platform.destination.application.dto;
import uim.platform.destination.presentation.http.json_utils;

class FindController {
  private FindDestinationUseCase uc;

  this(FindDestinationUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/destinations/find", &handleFind);
  }

  private void handleFind(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      FindDestinationRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.subaccountId = req.headers.get("X-Subaccount-Id", "");
      r.name = req.params.get("name");
      r.headerProvider = req.params.get("headerProvider");

      auto result = uc.find(r);

      if (!result.found) {
        writeError(res, 404, result.error);
        return;
      }

      auto j = Json.emptyObject;
      j["destinationName"] = Json(result.destinationName);
      j["url"] = Json(result.url);
      j["authentication"] = Json(result.authenticationType);
      j["proxyType"] = Json(result.proxyType);
      j["type"] = Json(result.destinationType);
      j["properties"] = toJsonObject(result.properties);
      j["appliedFragments"] = toJsonArray(result.appliedFragments);

      // Auth tokens
      auto tokenArr = Json.emptyArray;
      foreach (ref t; result.authTokens) {
        auto tj = Json.emptyObject;
        tj["type"] = Json(t.type_);
        tj["value"] = Json(t.value_);
        tj["expiresAt"] = Json(t.expiresAt);
        tj["httpHeaderSuggestion"] = Json(t.httpHeaderSuggestion);
        tokenArr ~= tj;
      }
      j["authTokens"] = tokenArr;

      // Certificates
      auto certArr = Json.emptyArray;
      foreach (ref c; result.certificates) {
        auto cj = Json.emptyObject;
        cj["name"] = Json(c.name);
        cj["type"] = Json(c.type_);
        cj["format"] = Json(c.format_);
        cj["status"] = Json(c.status);
        certArr ~= cj;
      }
      j["certificates"] = certArr;

      res.writeJsonBody(j, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
