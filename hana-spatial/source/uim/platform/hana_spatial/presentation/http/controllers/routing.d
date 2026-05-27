/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.routing;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class RoutingController : ManageController {
  private ManageRoutesUseCase usecase;

  this(ManageRoutesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/spatial/routes", &handleCreate);
    router.get("/api/v1/spatial/routes", &handleList);
    router.get("/api/v1/spatial/routes/*", &handleGet);
    router.delete_("/api/v1/spatial/routes/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CalculateRouteRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.originLat = jsonDouble(j, "originLat");
      r.originLon = jsonDouble(j, "originLon");
      r.destinationLat = jsonDouble(j, "destinationLat");
      r.destinationLon = jsonDouble(j, "destinationLon");
      r.originLabel = j.getString("originLabel");
      r.destinationLabel = j.getString("destinationLabel");
      r.travelMode = j.getString("travelMode");
      r.optimization = j.getString("optimization");
      r.language = j.getString("language");
      r.providerId = j.getString("providerId");

      auto result = usecase.calculateRoute(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Route calculated"), 201);
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
          .set("travelMode", item.travelMode.to!string)
          .set("totalDistanceMeters", item.totalDistanceMeters)
          .set("totalDurationSeconds", item.totalDurationSeconds)
          .set("originLabel", item.originLabel)
          .set("destinationLabel", item.destinationLabel)
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
        writeError(res, 404, "Route not found");
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
