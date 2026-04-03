module uim.platform.dms.application.presentation.http.controllers.folder;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.dms.application.application.usecases.manage_folders;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.types;
// import uim.platform.dms.application.presentation.http.json_utils;

import uim.platform.dms.application;
mixin(ShowModule!());
@safe:

class FolderController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.repositoryId = j.getString("repositoryId");
      r.parentFolderId = j.getString("parentFolderId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createFolder(r);
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listFolders(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref f; items)
        arr ~= serializeFolder(f);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto f = uc.getFolder(id, tenantId);
      if (f is null) {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = uc.updateFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.newParentFolderId = j.getString("newParentFolderId");

      auto result = uc.moveFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listChildren(parentId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref f; items)
        arr ~= serializeFolder(f);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteFolder(id, tenantId);
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
    auto j = Json.emptyObject;
    j["id"] = Json(f.id);
    j["tenantId"] = Json(f.tenantId);
    j["repositoryId"] = Json(f.repositoryId);
    j["parentFolderId"] = Json(f.parentFolderId);
    j["name"] = Json(f.name);
    j["description"] = Json(f.description);
    j["path"] = Json(f.path);
    j["createdBy"] = Json(f.createdBy);
    j["createdAt"] = Json(f.createdAt);
    j["updatedAt"] = Json(f.updatedAt);
    return j;
  }
}
