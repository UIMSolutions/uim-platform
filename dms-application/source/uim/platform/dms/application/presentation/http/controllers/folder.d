/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.folder;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.dms.application.application.usecases.manage.folders;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.types;
// import uim.platform.dms.application.presentation.http.json_utils;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class FolderController : PlatformController {
  private ManageFoldersUseCase uc;

  this(ManageFoldersUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/folders", &handleCreate);
    router.get("/api/v1/folders", &handleList);
    router.get("/api/v1/folders/*", &handleGetById);
    router.put("/api/v1/folders/*", &handleUpdate);
    router.delete_("/api/v1/folders/*", &handleDelete);
    router.post("/api/v1/folders/move/*", &handleMove);
    router.get("/api/v1/folders/children/*", &handleListChildren);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateFolderRequest();
      r.tenantId = req.getTenantId;
      r.repositoryId = j.getString("repositoryId");
      r.parentFolderId = j.getString("parentFolderId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Folder created"));

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listFolders(tenantId);

      auto arr = items.map!(f => f.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto f = uc.getFolder(tenantId, id);
      if (f.isNull) {
        writeError(res, 404, "Folder not found");
        return;
      }
      res.writeJsonBody(serializeFolder(f), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateFolderRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = uc.updateFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Folder updated"));
          
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Folder not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = MoveFolderRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.newParentFolderId = j.getString("newParentFolderId");

      auto result = uc.moveFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id));
          
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Folder not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListChildren(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto parentId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto items = uc.listChildren(tenantId, parentId);

      auto arr = items.map!(f => f.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteFolder(req.getTenantId, FolderId(id));

      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
