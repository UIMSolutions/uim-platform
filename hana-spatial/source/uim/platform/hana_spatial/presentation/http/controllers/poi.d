/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.poi;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class PoiController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreatePoiRequest r;
    r.tenantId = tenantId;
    r.poiId = PointOfInterestId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.latitude = jsonDouble(j, "latitude");
    r.longitude = jsonDouble(j, "longitude");
    r.street = data.getString("street");
    r.houseNumber = data.getString("houseNumber");
    r.city = data.getString("city");
    r.postalCode = data.getString("postalCode");
    r.country = data.getString("country");
    r.countryCode = data.getString("countryCode");
    r.phoneNumber = data.getString("phoneNumber");
    r.website = data.getString("website");
    r.openingHours = data.getString("openingHours");
    r.providerId = data.getString("providerId");
    r.externalId = data.getString("externalId");
    r.attributes = jsonKeyValuePairs(j, "attributes");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("POI created successfully", 201, Json.emptyObject.set("id", result.id));
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
        .set("category", item.category.to!string)
        .set("latitude", item.coordinate.latitude)
        .set("longitude", item.coordinate.longitude)
        .set("city", item.address.city)
        .set("countryCode", item.address.countryCode)
        .set("createdAt", item.createdAt);
    }

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", jarr);
    return successResponse("POI list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PointOfInterestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid POI ID", 400);

    auto item = usecase.getById(tenantId, id);
    if (item.isNull)
      return errorResponse("POI not found", 404);

    auto responseData = item.toJson();
    return successResponse("POI retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PointOfInterestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid POI ID", 400);

    auto data = precheck.data;
    UpdatePoiRequest r;
    r.tenantId = tenantId;
    r.poiId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.latitude = jsonDouble(j, "latitude");
    r.longitude = jsonDouble(j, "longitude");
    r.phoneNumber = data.getString("phoneNumber");
    r.website = data.getString("website");
    r.openingHours = data.getString("openingHours");

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("POI updated successfully", 200, Json.emptyObject.set("id", id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PointOfInterestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid POI ID", 400);

    auto result = usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("POI deleted successfully", 200, Json.emptyObject.set("id", id));
  }
}
