/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.geocoding_job;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
class GeocodingJobController : ManageHttpController {
  private ManageGeocodingJobsUseCase usecase;

  this(ManageGeocodingJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/spatial/geocodingJobs", &handleList);
    router.get("/api/v1/spatial/geocodingJobs/*", &handleGet);
    router.post("/api/v1/spatial/geocodingJobs", &handleCreate);
    router.post("/api/v1/spatial/geocodingJobs/*/action", &handleAction);
    router.delete_("/api/v1/spatial/geocodingJobs/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateGeocodingJobRequest r;
    r.tenantId = tenantId;
    r.jobId = GeocodingJobId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.providerId = data.getString("providerId");
    r.language = data.getString("language");
    r.countryCode = data.getString("countryCode");
    r.addresses = data.getStrings("addresses");
    r.externalRefs = data.getStrings("externalRefs");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Geocoding job created successfully", 201, Json.emptyObject.set("id", result
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
        .set("status", item.status.to!string)
        .set("totalItems", item.totalItems)
        .set("processedItems", item.processedItems)
        .set("failedItems", item.failedItems)
        .set("providerId", item.providerId)
        .set("createdAt", item.createdAt);
    }

    return successResponse("Geocoding job list retrieved successfully", 200, Json.emptyObject.set("count", Json(
        items.length)).set("resources", jarr));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GeocodingJobId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid geocoding job ID", 400);

    auto item = usecase.getById(tenantId, id);
    if (item.isNull)
      return errorResponse("", 0);

    return successResponse("Geocoding job retrieved successfully", 200, item.toJson());
  }

  private void handleAction(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = GeocodingJobId(precheck.id);
      if (id.isNull)
        return errorResponse("Invalid geocoding job ID", 400);

      auto data = precheck.data;
      GeocodingJobActionRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.action = data.getString("action");

      auto result = usecase.performAction(r);
      if (result.hasError)
        return errorResponse(result.message, 400);

      res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Action performed"), 200);
    } else {
      writeError(res, 400, result.message);
    }
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = GeocodingJobId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid geocoding job ID", 400);

  auto result = usecase.remove(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);
  
  return successResponse("Geocoding job deleted successfully", 200);
}
}
