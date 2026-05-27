/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.directory;

// 
// import uim.platform.management.application.usecases.manage.directories;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class DirectoryController : ManageController {
  private ManageDirectoriesUseCase usecase;

  this(ManageDirectoriesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/directories", &handleCreate);
    router.get("/api/v1/directories", &handleList);
    router.get("/api/v1/directories/*", &handleGet);
    router.put("/api/v1/directories/*", &handleUpdate);
    router.delete_("/api/v1/directories/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto gaId = req.params.get("globalAccountId");
    auto parentId = req.params.get("parentDirectoryId");

    Directory[] items;
    if (!parentId.isEmpty)
      items = usecase.listDirectories(tenantId, parentId);
    else if (!gaId.isEmpty)
      items = usecase.listDirectories(tenantId, gaId);

    auto arr = items.map!(d => d.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Directory list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateDirectoryRequest r;
    r.tenantId = tenantId;
    r.globalAccountId = data.getString("globalAccountId");
    r.parentDirectoryId = data.getString("parentDirectoryId");
    r.displayName = data.getString("displayName");
    r.description = data.getString("description");
    r.features = getStrings(data, "features");
    r.manageEntitlements = data.getBoolean("manageEntitlements");
    r.manageAuthorizations = data.getBoolean("manageAuthorizations");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));
    r.labels = jsonStrMap(data, "labels");
    r.customProperties = jsonStrMap(data, "customProperties");

    auto result = usecase.createDirectory(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Directory created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = DirectoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid directory ID", 400);

    auto d = usecase.getById(tenantId, id);
    if (job.isNull)
      return errorResponse("Directory not found", 404);

    auto responseData = d.toJson();
    return successResponse("Directory retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto data = precheck.data;

    auto id = DirectoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid directory ID", 400);

    UpdateDirectoryRequest request;
    request.displayName = data.getString("displayName");
    request.description = data.getString("description");
    request.labels = jsonStrMap(data, "labels");
    request.customProperties = jsonStrMap(data, "customProperties");

    auto result = usecase.update(tenantId, id, request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", id);
    return successResponse("Directory updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DirectoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid directory ID", 400);

    auto result = usecase.deleteDirectory(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", id);
    return successResponse("Directory deleted successfully", "Deleted", 200, responseData);
  }
}
