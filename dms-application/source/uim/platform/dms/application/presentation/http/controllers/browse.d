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

class BrowseController : SAPController {
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
    try
    {
      auto folderId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto contents = uc.browseFolderContents(folderId, tenantId);

      auto fArr = Json.emptyArray;
      foreach (ref f; contents.subfolders)
        fArr ~= serializeFolder(f);

      auto dArr = Json.emptyArray;
      foreach (ref d; contents.documents)
        dArr ~= serializeDoc(d);

      auto resp = Json.emptyObject;
      resp["subfolders"] = fArr;
      resp["documents"] = dArr;
      resp["totalSubfolders"] = Json(cast(long) contents.subfolders.length);
      resp["totalDocuments"] = Json(cast(long) contents.documents.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRepositorySummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto repoId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto summary = uc.getRepositorySummary(repoId, tenantId);

      if (summary.repositoryId.length == 0)
      {
        writeError(res, 404, "Repository not found");
        return;
      }

      auto j = Json.emptyObject;
      j["repositoryId"] = Json(summary.repositoryId);
      j["name"] = Json(summary.name);
      j["totalDocuments"] = Json(summary.totalDocuments);
      j["totalFolders"] = Json(summary.totalFolders);
      j["status"] = Json(summary.status.to!string);
      res.writeJsonBody(j, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAddFavorite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto j = req.json;
      auto r = CreateFavoriteRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.userId = req.headers.get("X-User-Id", "system");
      r.resourceId = j.getString("resourceId");
      r.resourceType = parseResourceType(j.getString("resourceType"));

      auto result = uc.addFavorite(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListFavorites(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto userId = req.headers.get("X-User-Id", "system");
      auto items = uc.getFavorites(userId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref f; items)
        arr ~= serializeFavorite(f);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRemoveFavorite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.removeFavorite(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeFolder(ref const Folder f) {
    auto j = Json.emptyObject;
    j["id"] = Json(f.id);
    j["name"] = Json(f.name);
    j["path"] = Json(f.path);
    j["parentFolderId"] = Json(f.parentFolderId);
    return j;
  }

  private static Json serializeDoc(ref const Document d) {
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["name"] = Json(d.name);
    j["mimeType"] = Json(d.mimeType);
    j["fileSize"] = Json(d.fileSize);
    j["status"] = Json(d.status.to!string);
    return j;
  }

  private static Json serializeFavorite(ref const Favorite f) {
    auto j = Json.emptyObject;
    j["id"] = Json(f.id);
    j["userId"] = Json(f.userId);
    j["resourceId"] = Json(f.resourceId);
    j["resourceType"] = Json(f.resourceType.to!string);
    j["createdAt"] = Json(f.createdAt);
    return j;
  }
}
