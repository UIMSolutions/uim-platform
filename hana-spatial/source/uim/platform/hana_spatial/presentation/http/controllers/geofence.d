/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.geofence;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:
class GeofenceController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateGeofenceZoneRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.shapeType = data.getString("shapeType");
    r.centerLat = jsonDouble(j, "centerLat");
    r.centerLon = jsonDouble(j, "centerLon");
    r.radiusMeters = jsonDouble(j, "radiusMeters");
    r.polygon = data.getString("polygon");
    r.active = data.getBoolean("active");
    r.metadata = jsonKeyValuePairs(j, "metadata");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Geofence zone created successfully", 201, Json.emptyObject.set("id", result
        .id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
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

    return successResponse("Geofence zones retrieved successfully", 200, Json.emptyObject.set("count", Json(
        items.length)).set("resources", jarr));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GeofenceZoneId(precheck.id);
    auto item = usecase.getById(tenantId, id);
    if (item.isNull)
      return errorResponse("Geofence zone not found", 404);

    return successResponse("Geofence zone retrieved successfully", 200, item.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GeofenceZoneId(precheck.id);
    auto data = precheck.data;
    UpdateGeofenceZoneRequest r;
    r.tenantId = tenantId;
    r.id = id;
    r.name = data.getString("name");
    r.description = dazoneIa.getString("description");
    r.radiusMeters = jsonDouble(j, "radiusMeters");
    r.polygon = data.getString("polygon");
    r.active = data.getBoolean("active");

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Geofence zone updated successfully", 200, Json.emptyObject.set(
        "id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GeofenceZoneId(precheck.id);
    auto result = usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Geofence zone deleted successfully", 200, Json.emptyObject.set(
        "id", result.id));
}

private void handleCheck(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    GeofenceCheckRequest r;
    r.tenantId = tenantId;
    r.zoneId = data.getString("zoneId");
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
