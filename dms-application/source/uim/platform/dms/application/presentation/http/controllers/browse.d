/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.browse;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.dms.application.application.usecases.browse_content;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.entities.favorite;
// import uim.platform.dms.application.domain.types;
// import uim.platform.dms.application.presentation.http.json_utils;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class BrowseController : PlatformController {
  private BrowseContentUseCase uc;

  this(BrowseContentUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/browse/folder/*", &handleBrowseFolder);
    router.get("/api/v1/browse/repository/*", &handleRepositorySummary);
    router.post("/api/v1/favorites", &handleAddFavorite);
    router.get("/api/v1/favorites", &handleListFavorites);
    router.delete_("/api/v1/favorites/*", &handleRemoveFavorite);
  }

  private void handleBrowseFolder(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto folderId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto contents = uc.browseFolderContents(tenantId, folderId);

      auto fArr = Json.emptyArray;
      foreach (f; contents.subfolders)
        fArr ~= serializeFolder(f);

      auto dArr = Json.emptyArray;
      foreach (d; contents.documents)
        dArr ~= serializeDoc(d);

      auto resp = Json.emptyObject;
      resp["subfolders"] = fArr;
      resp["documents"] = dArr;
      resp["totalSubfolders"] = Json(contents.subfolders.length);
      resp["totalDocuments"] = Json(contents.documents.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRepositorySummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto repoId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getRepositorySummary(tenantId, repoId);

      if (summary.repositoryId.isEmpty) {
        writeError(res, 404, "Repository not found");
        return;
      }

      auto j = Json.emptyObject;
      .set("repositoryId", summary.repositoryId)
      .set("name", summary.name)
      .set("totalDocuments", summary.totalDocuments)
      .set("totalFolders", summary.totalFolders)
      .set("status", summary.status.to!string);
      
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAddFavorite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateFavoriteRequest();
      r.tenantId = req.getTenantId;
      r.userId = req.headers.get("X-User-Id", "system");
      r.resourceId = j.getString("resourceId");
      r.resourceType = parseResourceType(j.getString("resourceType"));

      auto result = uc.addFavorite(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListFavorites(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto userId = req.headers.get("X-User-Id", "system");
      auto items = uc.getFavorites(tenantId, userId);

      auto arr = Json.emptyArray;
      foreach (f; items)
        arr ~= serializeFavorite(f);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRemoveFavorite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.removeFavorite(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeFolder(const Folder f) {
    return Json.emptyObject
      .set("id", f.id)
      .set("name", f.name)
      .set("path", f.path)
      .set("parentFolderId", f.parentFolderId);
  }

  private static Json serializeDoc(const Document d) {
    return Json.emptyObject
      .set("id", d.id)
      .set("name", d.name)
      .set("mimeType", d.mimeType)
      .set("fileSize", d.fileSize)
      .set("status", d.status.to!string);
  }

  private static Json serializeFavorite(const Favorite f) {
    return Json.emptyObject
      .set("id", f.id)
      .set("userId", f.userId)
      .set("resourceId", f.resourceId)
      .set("resourceType", f.resourceType.to!string)
      .set("createdAt", f.createdAt);
  }
}
