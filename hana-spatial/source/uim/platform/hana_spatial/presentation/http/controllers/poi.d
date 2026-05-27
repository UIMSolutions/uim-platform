/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.poi;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class PoiController : ManageController {
  private ManagePointsOfInterestUseCase usecase;

  this(ManagePointsOfInterestUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/spatial/poi", &handleList);
    router.get("/api/v1/spatial/poi/*", &handleGet);
    router.post("/api/v1/spatial/poi", &handleCreate);
    router.put("/api/v1/spatial/poi/*", &handleUpdate);
    router.delete_("/api/v1/spatial/poi/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      CreatePoiRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.latitude = jsonDouble(j, "latitude");
      r.longitude = jsonDouble(j, "longitude");
      r.street = j.getString("street");
      r.houseNumber = j.getString("houseNumber");
      r.city = j.getString("city");
      r.postalCode = j.getString("postalCode");
      r.country = j.getString("country");
      r.countryCode = j.getString("countryCode");
      r.phoneNumber = j.getString("phoneNumber");
      r.website = j.getString("website");
      r.openingHours = j.getString("openingHours");
      r.providerId = j.getString("providerId");
      r.externalId = j.getString("externalId");
      r.attributes = jsonKeyValuePairs(j, "attributes");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "POI created"), 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (item; items) {
        jarr ~= Json.emptyObject
          .set("id", item.id.value)
          .set("name", item.name)
          .set("category", item.category.to!string)
          .set("latitude", item.coordinate.latitude)
          .set("longitude", item.coordinate.longitude)
          .set("city", item.address.city)
          .set("countryCode", item.address.countryCode)
          .set("createdAt", item.createdAt);
      }

      res.writeJsonBody(Json.emptyObject.set("count", Json(items.length)).set("resources", jarr), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto item = usecase.getById(tenantId, id);
      if (item.isNull) {
        writeError(res, 404, "POI not found");
        return;
      }
      res.writeJsonBody(item.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto j = req.json;
      UpdatePoiRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.latitude = jsonDouble(j, "latitude");
      r.longitude = jsonDouble(j, "longitude");
      r.phoneNumber = j.getString("phoneNumber");
      r.website = j.getString("website");
      r.openingHours = j.getString("openingHours");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "POI updated"), 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
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
