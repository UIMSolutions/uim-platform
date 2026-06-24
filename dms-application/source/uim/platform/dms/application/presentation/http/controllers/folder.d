/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.folder;

// 
// 
// import uim.platform.dms.application.application.usecases.manage.folders;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

// mixin(ShowModule!());
@safe:

class FolderController : ManageHttpController {
  private ManageFoldersUseCase usecase;

  this(ManageFoldersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/folders", &handleCreate);
    router.get("/api/v1/folders", &handleList);
    router.get("/api/v1/folders/*", &handleGet);
    router.put("/api/v1/folders/*", &handleUpdate);
    router.delete_("/api/v1/folders/*", &handleDelete);
    router.post("/api/v1/folders/move/*", &handleMove);
    router.get("/api/v1/folders/children/*", &handleListChildren);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateFolderRequest();
    r.tenantId = tenantId;
    r.repositoryId = data.getString("repositoryId");
    r.parentFolderId = data.getString("parentFolderId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createFolder(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Folder created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listFolders(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = FolderId(precheck.id);

    auto folder = usecase.getFolder(tenantId, id);
    if (folder.isNull) 
    return errorResponse("Folder not found", 404);

    return successResponse("Folder retrieved successfully", "Retrieved", 200, folder.toJson);
}

/**
    * Handles updating folder metadata (name, description).
    * The folder ID is extracted from the URL path.
    */
override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = FolderId(precheck.id);
  auto data = precheck.data;
  auto r = UpdateFolderRequest();
  r.folderId = id;
  r.tenantId = tenantId;
  r.name = data.getString("name");
  r.description = data.getString("description");

  auto result = usecase.updateFolder(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Folder updated successfully", "Updated", 200, resp);
}

protected Json moveHandler(HTTPServerRequest req) {
  auto precheck = super.postHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = FolderId(precheck.id);
  auto data = precheck.data;
  auto r = MoveFolderRequest();
  r.folderId = id;
  r.tenantId = tenantId;
  r.newParentFolderId = data.getString("newParentFolderId");

  auto result = usecase.moveFolder(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto resp = Json.emptyObject
    .set("id", result.id);
  return successResponse("Folder moved successfully", "Moved", 200, resp);
}

protected void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto response = moveHandler(req);
    res.writeJsonBody(response, response.code);
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

protected Json listChildrenHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto parentId = FolderId(precheck.id);

  auto subfolders = usecase.listSubfolders(tenantId, parentId);
  auto arr = subfolders.map!(f => f.toJson()).array.toJson;

  auto resp = Json.emptyObject
    .set("items", arr)
    .set("totalCount", subfolders.length)
    .set("message", "Child folders retrieved successfully");

  return successResponse("", "Retrieved", 200, resp);
}

mixin(HandleTemplate!("handleListChildren", "listChildrenHandler"));

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = FolderId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid folder ID", 400);
    
  auto result = usecase.deleteFolder(tenantId, id);
  if (result.hasError) 
    return errorResponse(result.message, 400);

  auto resp = Json.emptyObject
    .set("id", result.id);
  return successResponse("Folder deleted successfully", "Deleted", 200, resp);
}
}
