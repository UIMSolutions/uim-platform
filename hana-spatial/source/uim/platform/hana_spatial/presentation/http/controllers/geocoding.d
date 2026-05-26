/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.geocoding;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class GeocodingController : ManageController {
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
      auto tenantId = req.getTenantId;
      auto j = req.json;
      GeocodeAddressRequest r;
      r.tenantId = tenantId;
      r.id = j.getString("id");
      r.address = j.getString("address");
      r.language = j.getString("language");
      r.countryCode = j.getString("countryCode");
      r.providerId = j.getString("providerId");

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
      auto tenantId = req.getTenantId;
      auto j = req.json;
      ReverseGeocodeRequest r;
      r.tenantId = tenantId;
      r.id = j.getString("id");
      r.latitude = jsonDouble(j, "latitude");
      r.longitude = jsonDouble(j, "longitude");
      r.language = j.getString("language");
      r.providerId = j.getString("providerId");

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

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto items = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (item; items) {
        jarr ~= Json.emptyObject
          .set("id", item.id.value)
          .set("type", item.type.to!string)
          .set("matchLevel", item.matchLevel.to!string)
          .set("confidence", item.confidence)
          .set("inputQuery", item.inputQuery)
          .set("providerId", item.providerId)
          .set("createdAt", item.createdAt);
      }

      res.writeJsonBody(Json.emptyObject.set("count", Json(items.length)).set("resources", jarr), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto item = usecase.getById(tenantId, id);
      if (item.isNull) {
        writeError(res, 404, "Geocoding result not found");
        return;
      }
      res.writeJsonBody(item.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto result = usecase.remove(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
