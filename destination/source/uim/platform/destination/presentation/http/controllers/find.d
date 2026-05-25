/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.find;

// import uim.platform.destination.application.usecases.find_destination;
// import uim.platform.destination.application.dto;
// import uim.platform.destination.presentation.http
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class FindController : PlatformController {
  private FindDestinationUseCase usecase;

  this(FindDestinationUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/destinations/find", &handleFind);
  }

  protected Json findHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    FindDestinationRequest r;
    r.tenantId = precheck.tenantId;
    r.subaccountId = req.headers.get("X-Subaccount-Id", "");
    r.name = req.params.get("name");
    r.headerProvider = req.params.get("headerProvider");

    auto result = usecase.find(r);
    if (!result.found)
      return errorResponse("Destination not found", 404);

    auto propsJson = Json.emptyObject;
    foreach (k, v; result.properties)
      propsJson[k] = Json(v);

    auto fragArr = result.appliedFragments.map!(s => Json(s)).array.toJson;

    // Auth tokens
    auto tokenArr = Json.emptyArray;
    foreach (t; result.authTokens) {
      tokenArr ~= Json.emptyObject
        .set("type", t.type_)
        .set("value", t.value_)
        .set("expiresAt", t.expiresAt)
        .set("httpHeaderSuggestion", t.httpHeaderSuggestion);
    }

    auto certArr = Json.emptyArray;
    foreach (c; result.certificates) {
      certArr ~= Json.emptyObject
        .set("name", c.name)
        .set("type", c.type_)
        .set("format", c.format_)
        .set("status", c.status);
    }

    auto j = Json.emptyObject
      .set("destinationName", result.destinationName)
      .set("url", result.url)
      .set("authentication", result.authenticationType)
      .set("proxyType", result.proxyType)
      .set("type", result.destinationType)
      .set("properties", propsJson)
      .set("appliedFragments", fragArr)
      .set("authTokens", tokenArr.toJson)
      .set("certificates", certArr.toJson);

    return successResponse("Destination found", "Found", 200, j);
  }

  protected void handleFind(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = findHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
