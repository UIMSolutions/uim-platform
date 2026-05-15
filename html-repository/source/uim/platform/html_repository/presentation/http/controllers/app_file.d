/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_file;
// import uim.platform.html_repository.application.usecases.manage.app_files;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppFileController : PlatformController {
  private ManageAppFilesUseCase usecase;

  this(ManageAppFilesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/files", &handleCreate);
    router.get("/api/v1/files", &handleList);
    router.get("/api/v1/files/*", &handleGet);
    router.put("/api/v1/files/*", &handleUpdate);
    router.delete_("/api/v1/files/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      UploadAppFileRequest r;
      r.tenantId = tenantId;
      r.versionId = j.getString("versionId");
      r.filePath = j.getString("filePath");
      r.contentType = j.getString("contentType");
      r.data = j.getString("data");
      r.encoding = j.getString("encoding");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = usecase.uploadAppFile(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto versionId = getString(req.json, "versionId");
      if (versionId.isEmpty)
        versionId = req.headers.get("X-Version-Id", "");

      auto items = usecase.listAppFiles(tenantId, versionId);
      auto arr = Json.emptyArray;
      foreach (e; items) {
        auto obj = Json.emptyObject
          .set("id", e.id)
          .set("filePath", e.filePath)
          .set("contentType", e.contentType)
          .set("category", e.category)
          .set("sizeBytes", e.sizeBytes);

        arr ~= obj;
      }

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
      auto id = AppFileId(extractIdFromPath(req.requestURI.to!string));
      auto tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "File not found");
        return;
      }
      auto entry = usecase.getAppFile(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "File not found");
        return;
      }
      auto response = Json.emptyObject
        .set("id", entry.id)
        .set("versionId", entry.versionId)
        .set("filePath", entry.filePath)
        .set("contentType", entry.contentType)
        .set("category", entry.category)
        .set("sizeBytes", entry.sizeBytes)
        .set("data", entry.data)
        .set("encoding", entry.encoding)
        .set("createdBy", entry.createdBy)
        .set("createdAt", entry.createdAt)
        .set("updatedAt", entry.updatedAt);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto id = AppFileId(extractIdFromPath(req.requestURI.to!string));

      auto tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "File not found");
        return;
      }
      UpdateAppFileRequest r;
      r.contentType = j.getString("contentType");
      r.data = j.getString("data");
      r.encoding = j.getString("encoding");

      auto result = usecase.updateAppFile(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", id)
          .set("message", "File updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = AppFileId(extractIdFromPath(req.requestURI.to!string));
      if (id.isEmpty) {
        writeError(res, 404, "File not found");
        return;
      }
      auto result = usecase.deleteAppFile(tenantId, id);
      if (result.isSuccess())
        res.writeBody("", 204);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
