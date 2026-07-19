/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.repository;

// 
// 
// import uim.platform.dms.application.application.usecases.manage.repositories;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;
mixin(ShowModule!());
@safe:

class RepositoryController : ManageHttpController {
  private ManageRepositoriesUseCase usecase;

  this(ManageRepositoriesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/repositories", &handleCreate);
    router.get("/api/v1/repositories", &handleList);
    router.get("/api/v1/repositories/*", &handleGet);
    router.put("/api/v1/repositories/*", &handleUpdate);
    router.delete_("/api/v1/repositories/*", &handleDelete);
    router.post("/api/v1/repositories/activate/*", &handleActivate);
    router.post("/api/v1/repositories/archive/*", &handleArchive);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateRepositoryRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.maxFileSize = data.getLong("maxFileSize");
    r.allowedFileTypes = data.getString("allowedFileTypes");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createRepository(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("DmsRepository created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listRepositories(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Repositories retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RepositoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid repository ID", 400);

    auto repository = usecase.getRepository(tenantId, id);
    if (repository.isNull)
      return errorResponse("DmsRepository not found", 404);

    auto responseData = Json.emptyObject.set("id", repository.id);
    return successResponse("DmsRepository retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RepositoryId(precheck.id);
    auto data = precheck.data;
    auto r = UpdateRepositoryRequest();
    r.repositoryId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.maxFileSize = data.getLong("maxFileSize");
    r.allowedFileTypes = data.getString("allowedFileTypes");

    auto result = usecase.updateRepository(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("DmsRepository updated successfully", "Updated", 200, responseData);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RepositoryId(precheck.id);

    auto result = usecase.activateRepository(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", "active");

    return successResponse("DmsRepository activated successfully", "Activated", 200, resp);
  }

  mixin(HandleTemplate!("handleActivate", "activateHandler"));

  protected Json archiveHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RepositoryId(precheck.id);

    auto result = usecase.archiveRepository(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", Json("archived"));

    return successResponse("DmsRepository archived successfully", "Archived", 200, resp);
  }

  mixin(HandleTemplate!("handleArchive", "archiveHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RepositoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid repository ID", 400);

    auto result = usecase.deleteRepository(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("DmsRepository deleted successfully", 200, responseData);
  }
}
