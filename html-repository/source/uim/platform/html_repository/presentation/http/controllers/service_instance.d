/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.service_instance;

// import uim.platform.html_repository.application.usecases.manage.service_instances;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class ServiceInstanceController : ManageHttpController {
  private ManageServiceInstancesUseCase usecase;

  this(ManageServiceInstancesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/instances", &handleCreate);
    router.get("/api/v1/instances", &handleList);
    router.get("/api/v1/instances/*", &handleGet);
    router.put("/api/v1/instances/*", &handleUpdate);
    router.delete_("/api/v1/instances/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateServiceInstanceRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.spaceId = data.getString("spaceId");
    r.plan = data.getString("plan");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Service instance created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listByTenant(tenantId);

    auto arr = Json.emptyArray;
    foreach (e; items) {
      arr ~= Json.emptyObject
        .set("id", e.id)
        .set("name", e.name)
        .set("plan", e.plan)
        .set("status", e.status)
        .set("appCount", e.appCount);
    }

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Service instances retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    if (id.isNull)
      return errorResponse("Service instance not found", 404);

    auto entry = usecase.getById(tenantId, id);
    if (entry.isNull)
      return errorResponse("Service instance not found", 404);

    auto response = Json.emptyObject
      .set("id", entry.id)
      .set("name", entry.name)
      .set("description", entry.description)
      .set("spaceId", entry.spaceId)
      .set("plan", entry.plan)
      .set("status", entry.status)
      .set("appCount", entry.appCount)
      .set("createdBy", entry.createdBy)
      .set("createdAt", entry.createdAt)
      .set("updatedBy", entry.updatedBy)
      .set("updatedAt", entry.updatedAt);

    return successResponse("Service instance retrieved successfully", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    if (id.isNull)
      return errorResponse("Service instance not found", 404);

    UpdateServiceInstanceRequest r;
    r.id = id;
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.updatedBy = UserId(data.getString("updatedBy"));

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Service instance updated successfully", "Updated", 200, result);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceInstanceId(precheck.id);
    if (id.isNull)
      return errorResponse("Service instance not found", 404);

    auto tenantId = precheck.tenantId;
    if (id.isNull)
      return errorResponse("Service instance not found", 404);

    auto result = usecase.deleteServiceInstance(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Service instance deleted successfully", "Deleted", 200, Json.emptyObject.set("id", id));
  }
}
