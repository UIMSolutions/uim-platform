/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.routing;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class RoutingController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    CalculateRouteRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.originLat = jsonDouble(j, "originLat");
    r.originLon = jsonDouble(j, "originLon");
    r.destinationLat = jsonDouble(j, "destinationLat");
    r.destinationLon = jsonDouble(j, "destinationLon");
    r.originLabel = data.getString("originLabel");
    r.destinationLabel = data.getString("destinationLabel");
    r.travelMode = data.getString("travelMode");
    r.optimization = data.getString("optimization");
    r.language = data.getString("language");
    r.providerId = data.getString("providerId");

    auto result = usecase.calculateRoute(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    
    return successResponse("Route calculated successfully", 201, Json.emptyObject.set("id", result.id));
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
      .set("travelMode", item.travelMode.to!string)
      .set("totalDistanceMeters", item.totalDistanceMeters)
      .set("totalDurationSeconds", item.totalDurationSeconds)
      .set("originLabel", item.originLabel)
      .set("destinationLabel", item.destinationLabel)
      .set("providerId", item.providerId)
      .set("createdAt", item.createdAt);
  }

  return successResponse("Routes retrieved successfully", "Retrieved", 200, Json.emptyObject.set("count", Json(items.length)).set("resources", jarr));
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto item = usecase.getById(tenantId, id);
  if (item.isNull)
    return errorResponse("Route not found", 404);

  return successResponse("Route retrieved successfully", "Retrieved", 200, item.toJson);
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

  return successResponse("Route deleted successfully", "Deleted", 200, Json.emptyObject);
}
}
