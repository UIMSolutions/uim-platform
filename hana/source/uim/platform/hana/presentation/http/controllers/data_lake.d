/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.data_lake;
// import uim.platform.hana.application.usecases.manage.data_lakes;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

// mixin(ShowModule!());

@safe:

/** 
  * Controller for managing data lakes in the HANA platform. Provides endpoints for creating, retrieving, updating, and deleting data lakes.
  *
  * Endpoints:
  * - GET /api/v1/hana/dataLakes: List all data lakes for the tenant.
  * - GET /api/v1/hana/dataLakes/{id}: Get details of a specific data lake by ID.
  * - POST /api/v1/hana/dataLakes: Create a new data lake.
  * - PUT /api/v1/hana/dataLakes/{id}: Update an existing data lake by ID.
  * - DELETE /api/v1/hana/dataLakes/{id}: Delete a data lake by ID.
  * 
  * Each endpoint requires tenant authentication and appropriate permissions. The controller interacts with the ManageDataLakesUseCase to perform business logic and returns JSON responses with appropriate HTTP status codes.
  */
class DataLakeController : ManageHttpController {
  private ManageDataLakesUseCase usecase;

  this(ManageDataLakesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/hana/dataLakes", &handleList);
    router.get("/api/v1/hana/dataLakes/*", &handleGet);
    router.post("/api/v1/hana/dataLakes", &handleCreate);
    router.put("/api/v1/hana/dataLakes/*", &handleUpdate);
    router.delete_("/api/v1/hana/dataLakes/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataLakeRequest r;
    r.tenantId = tenantId;
    r.instanceId = data.getString("instanceId");
    r.id = precheck.id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.computeNodes = data.getInteger("computeNodes", 1);
    r.storage = jsonKeyValuePairs(j, "storage");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Data lake created");

    return successResponse("Data lake created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto lakes = usecase.list(tenantId);

    auto jarr = Json.emptyArray;
    foreach (d; lakes) {
      jarr ~= Json.emptyObject
        .set("id", d.id)
        .set("instanceId", d.instanceId)
        .set("name", d.name)
        .set("description", d.description)
        .set("status", d.status.to!string)
        .set("computeNodes", d.computeNodes)
        .set("createdAt", d.createdAt)
        .set("updatedAt", d.updatedAt);
    }

    auto resp = Json.emptyObject
      .set("count", Json(lakes.length))
      .set("resources", list);

    return successResponse("Data lake list retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto d = usecase.getById(tenantId, id);
    if (d.isNull)
      return errorResponse("", 0);

    auto resp = Json.emptyObject
      .set("id", d.id)
      .set("instanceId", d.instanceId)
      .set("name", d.name)
      .set("description", d.description)
      .set("status", d.status.to!string)
      .set("computeNodes", d.computeNodes)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);

    return successResponse("Data lake retrieved successfully", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataLakeId(precheck.id);
    if (id.isNull)
      return errorResponse("Data lake not found", 404);

    auto data = precheck.data;
    UpdateDataLakeRequest r;
    r.tenantId = tenantId;
    r.lakeId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.computeNodes = data.getInteger("computeNodes", 1);

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Data lake updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataLakeId(precheck.id);
    if (id.isNull)
      return errorResponse("Data lake not found", 404);

    auto result = usecase.deleteDataLake(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Data lake deleted successfully", "Deleted", 200, Json.emptyObject.set(
        "id", id));
  }
}
