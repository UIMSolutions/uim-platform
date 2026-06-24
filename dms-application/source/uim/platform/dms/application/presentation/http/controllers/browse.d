/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.browse;

// 
// 
// import uim.platform.dms.application.application.usecases.browse_content;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.entities.favorite;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

// mixin(ShowModule!());
@safe:

class BrowseController : HttpController {
  private BrowseContentUseCase usecase;

  this(BrowseContentUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/browse/folder/*", &handleBrowseFolder);
    router.get("/api/v1/browse/repository/*", &handleRepositorySummary);
    router.post("/api/v1/favorites", &handleAddFavorite);
    router.get("/api/v1/favorites", &handleListFavorites);
    router.delete_("/api/v1/favorites/*", &handleDeleteFavorite);
  }

  protected Json browseFolderHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto folderId = FolderId(precheck.id);
    auto tenantId = precheck.tenantId;
    auto contents = usecase.browseFolderContents(tenantId, folderId);

    auto fArr = contents.subfolders.map!(f => f.toJson).array.toJson;
    auto dArr = contents.documents.map!(d => d.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("subfolders", fArr)
      .set("documents", dArr)
      .set("totalSubfolders", contents.subfolders.length)
      .set("totalDocuments", contents.documents.length)
      .set("message", "Folder contents retrieved successfully");

    return successResponse("Folder contents retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleBrowseFolder", "browseFolderHandler"));

  protected Json getRepositorySummaryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto repoId = RepositoryId(precheck.id);
    auto tenantId = precheck.tenantId;
    auto summary = usecase.getRepositorySummary(tenantId, repoId);

    if (summary.repositoryId.isEmpty)
      return errorResponse("Repository not found", 404);

    auto j = Json.emptyObject
      .set("repositoryId", summary.repositoryId)
      .set("name", summary.name)
      .set("totalDocuments", summary.totalDocuments)
      .set("totalFolders", summary.totalFolders)
      .set("status", summary.status.to!string)
      .set("message", "Repository summary retrieved successfully");

    return successResponse("Repository summary retrieved successfully", "Retrieved", 200, j);
  }

  mixin(HandleTemplate!("handleRepositorySummary", "getRepositorySummaryHandler"));

  protected Json addFavoriteHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CreateFavoriteRequest();
    r.tenantId = tenantId;
    r.userId = UserId(req.headers.get("X-User-Id", "system"));
    r.resourceId = data.getString("resourceId");
    r.resourceType = data.getString("resourceType").to!ResourceType;

    auto result = usecase.addFavorite(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Favorite added successfully");

    return successResponse("Favorite added successfully", "Created", 201, resp);
  }

  mixin(HandleTemplate!("handleAddFavorite", "addFavoriteHandler"));

  protected Json listFavoritesHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto userId = UserId(req.headers.get("X-User-Id", "system"));
    auto items = usecase.getFavorites(tenantId, userId);

    auto list = items.map!(f => f.toJson).array.toJson;
    auto resp = Json.emptyObject
      .set("items", list)
      .set("totalCount", items.length);

    return successResponse("Favorites retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleListFavorites", "listFavoritesHandler"));

  protected Json deleteFavoriteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = FavoriteId(precheck.id);
    if (id.isEmpty)
      return errorResponse("Invalid favorite ID", 400);

    auto result = usecase.deleteFavorite(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("deleted", true);

    return successResponse("Favorite removed successfully", "Deleted", 200, resp);
  }

  mixin(HandleTemplate!("handleDeleteFavorite", "deleteFavoriteHandler"));

}
