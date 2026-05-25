/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.geofence;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class GeofenceController : ManageController {
  private ManageGeofenceZonesUseCase usecase;

  this(ManageGeofenceZonesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/spatial/geofences", &handleList);
    router.get("/api/v1/spatial/geofences/*", &handleGet);
    router.post("/api/v1/spatial/geofences", &handleCreate);
    router.put("/api/v1/spatial/geofences/*", &handleUpdate);
    router.delete_("/api/v1/spatial/geofences/*", &handleDelete);
    router.post("/api/v1/spatial/geofences/check", &handleCheck);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateGeofenceZoneRequest r;
      r.tenantId = tenantId;
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.shapeType = j.getString("shapeType");
      r.centerLat = jsonDouble(j, "centerLat");
      r.centerLon = jsonDouble(j, "centerLon");
      r.radiusMeters = jsonDouble(j, "radiusMeters");
      r.polygon = j.getString("polygon");
      r.active = j.getBoolean("active");
      r.metadata = jsonKeyValuePairs(j, "metadata");

      auto result = usecase.create(r);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Geofence zone created"), 201);
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
          .set("name", item.name)
          .set("shapeType", item.shapeType.to!string)
          .set("active", item.active)
          .set("radiusMeters", item.radiusMeters)
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
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto item = usecase.getById(tenantId, id);
      if (item.isNull) {
        writeError(res, 404, "Geofence zone not found");
        return;
      }
      res.writeJsonBody(item.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateGeofenceZoneRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.radiusMeters = jsonDouble(j, "radiusMeters");
      r.polygon = j.getString("polygon");
      r.active = j.getBoolean("active");

      auto result = usecase.update(r);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Geofence zone updated"), 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = usecase.remove(tenantId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCheck(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      GeofenceCheckRequest r;
      r.tenantId = tenantId;
      r.zoneId = j.getString("zoneId");
      r.latitude = jsonDouble(j, "latitude");
      r.longitude = jsonDouble(j, "longitude");

      auto checkResult = usecase.checkPoint(r);
      res.writeJsonBody(Json.emptyObject
        .set("inside", checkResult.inside)
        .set("zoneId", checkResult.zoneId)
        .set("zoneName", checkResult.zoneName), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
