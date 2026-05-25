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

mixin(ShowModule!());
@safe:

class FolderController : ManageController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateFolderRequest();
      r.tenantId = tenantId;
      r.repositoryId = j.getString("repositoryId");
      r.parentFolderId = j.getString("parentFolderId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Folder created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto items = usecase.listFolders(tenantId);

      auto arr = items.map!(f => f.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = FolderId(extractIdFromPath(req.requestURI));
      
      auto folder = usecase.getFolder(tenantId, id);
      if (folder.isNull) {
        writeError(res, 404, "Folder not found");
        return;
      }
      res.writeJsonBody(folder.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  /**
    * Handles updating folder metadata (name, description).
    * The folder ID is extracted from the URL path.
    */
  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = FolderId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdateFolderRequest();
      r.folderId = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = usecase.updateFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Folder updated");
          
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Folder not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = FolderId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = MoveFolderRequest();
      r.folderId = id;
      r.tenantId = tenantId;
      r.newParentFolderId = j.getString("newParentFolderId");

      auto result = usecase.moveFolder(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Folder moved");
          
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Folder not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleListChildren(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto parentId = FolderId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;

      auto subfolders = usecase.listSubfolders(tenantId, parentId);
      auto arr = subfolders.map!(f => f.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", subfolders.length)
        .set("message", "Child folders retrieved successfully");

        res.writeJsonBody(resp, 200);
      } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = FolderId(extractIdFromPath(req.requestURI));
      auto result = usecase.deleteFolder(req.getTenantId, id);

      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
