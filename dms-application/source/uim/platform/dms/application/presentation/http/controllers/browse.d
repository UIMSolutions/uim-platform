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

  protected void handleGetBrowseFolder(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
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

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleRepositorySummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto repoId = RepositoryId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto summary = usecase.getRepositorySummary(tenantId, repoId);

      if (summary.repositoryId.isEmpty) {
        writeError(res, 404, "Repository not found");
        return;
      }

      auto j = Json.emptyObject
        .set("repositoryId", summary.repositoryId)
        .set("name", summary.name)
        .set("totalDocuments", summary.totalDocuments)
        .set("totalFolders", summary.totalFolders)
        .set("status", summary.status.to!string)
        .set("message", "Repository summary retrieved successfully");

      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleAddFavorite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateFavoriteRequest();
      r.tenantId = tenantId;
      r.userId = UserId(req.headers.get("X-User-Id", "system"));
      r.resourceId = data.getString("resourceId");
      r.resourceType = data.getString("resourceType").to!ResourceType;

      auto result = usecase.addFavorite(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Favorite added successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleListFavorites(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto userId = UserId(req.headers.get("X-User-Id", "system"));
      auto items = usecase.getFavorites(tenantId, userId);

      auto list = items.map!(f => f.toJson).array.toJson;
      auto resp = Json.emptyObject
        .set("items", list)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDeleteFavorite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = FavoriteId(precheck.id);

      auto result = usecase.deleteFavorite(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Favorite removed successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
