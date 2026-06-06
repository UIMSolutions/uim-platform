/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.geocoding;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class GeocodingController : ManageHttpController {
  private ManageGeocodingResultsUseCase usecase;

  this(ManageGeocodingResultsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/spatial/geocode", &handleGeocode);
    router.post("/api/v1/spatial/reverseGeocode", &handleReverseGeocode);
    router.get("/api/v1/spatial/geocode", &handleList);
    router.get("/api/v1/spatial/geocode/*", &handleGet);
    router.delete_("/api/v1/spatial/geocode/*", &handleDelete);
  }

  private void handleGeocode(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      GeocodeAddressRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.address = data.getString("address");
      r.language = data.getString("language");
      r.countryCode = data.getString("countryCode");
      r.providerId = data.getString("providerId");

      auto result = usecase.geocodeAddress(r);
      if (result.hasError)
        return errorResponse(result.message, 400);
      res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Geocoding result stored"), 201);
    } else {
      writeError(res, 400, result.message);
    }
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

private void handleReverseGeocode(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    ReverseGeocodeRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.latitude = jsonDouble(j, "latitude");
    r.longitude = jsonDouble(j, "longitude");
    r.language = data.getString("language");
    r.providerId = data.getString("providerId");

    auto result = usecase.reverseGeocode(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Reverse geocoding result stored"), 201);
  } else {
    writeError(res, 400, result.message);
  }
} catch (Exception e) {
  writeError(res, 500, "Internal server error");
}
}

override protected Json listHandler(HTTPServerRequest req) {
  auto precheck = super.listHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto items = usecase.list(tenantId);

  auto list = Json.emptyArray;
  foreach (item; items) {
    list ~= Json.emptyObject
      .set("id", item.id.value)
      .set("type", item.type.to!string)
      .set("matchLevel", item.matchLevel.to!string)
      .set("confidence", item.confidence)
      .set("inputQuery", item.inputQuery)
      .set("providerId", item.providerId)
      .set("createdAt", item.createdAt);
  }

  auto responseData = Json.emptyObject
    .set("count", list.length)
    .set("resources", list);
  return successResponse("Geocoding results retrieved successfully", "Retrieved", 200, responseData);
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto item = usecase.getById(tenantId, id);
  if (item.isNull)
    return errorResponse("Scan job not found", 404);

  auto responseData = item.toJson();
  return successResponse("Geocoding result retrieved successfully", "Retrieved", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto result = usecase.remove(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Geocoding result deleted successfully", "Deleted", 200, responseData);
}
}
