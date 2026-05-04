/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_file;

// import uim.platform.html_repository.application.usecases.manage.app_files;
// import uim.platform.html_repository.application.dto;

// import uim.platform.htmls;

// import std.conv : to;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppFileController : PlatformController {
  private ManageAppFilesUseCase uc;

  this(ManageAppFilesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/files", &handleCreate);
    router.get("/api/v1/files", &handleList);
    router.get("/api/v1/files/*", &handleGet);
    router.put("/api/v1/files/*", &handleUpdate);
    router.delete_("/api/v1/files/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UploadAppFileRequest r;
      r.tenantId = req.getTenantId;
      r.versionId = j.getString("versionId");
      r.filePath = j.getString("filePath");
      r.contentType = j.getString("contentType");
      r.data = j.getString("data");
      r.encoding = j.getString("encoding");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = uc.upload(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto versionId = getString(req.json, "versionId");
      if (versionId.isEmpty)
        versionId = req.headers.get("X-Version-Id", "");
      auto items = uc.listByVersion(versionId);

      auto arr = Json.emptyArray;
      foreach (e; items) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(e.id);
        obj["filePath"] = Json(e.filePath);
        obj["contentType"] = Json(e.contentType);
        obj["category"] = Json(e.category);
        obj["sizeBytes"] = Json(e.sizeBytes);
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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "File not found");
        return;
      }
      auto entry = uc.getById(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "File not found");
        return;
      }
      auto obj = Json.emptyObject;
      obj["id"] = Json(entry.id);
      obj["versionId"] = Json(entry.versionId);
      obj["filePath"] = Json(entry.filePath);
      obj["contentType"] = Json(entry.contentType);
      obj["category"] = Json(entry.category);
      obj["sizeBytes"] = Json(entry.sizeBytes);
      obj["data"] = Json(entry.data);
      obj["encoding"] = Json(entry.encoding);
      obj["createdBy"] = Json(entry.createdBy);
      obj["createdAt"] = Json(entry.createdAt);
      obj["updatedAt"] = Json(entry.updatedAt);

      res.writeJsonBody(obj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    } 
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "File not found");
        return;
      }
      UpdateAppFileRequest r;
      r.contentType = j.getString("contentType");
      r.data = j.getString("data");
      r.encoding = j.getString("encoding");

      auto result = uc.update(r);
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "File not found");
        return;
      }
      auto result = uc.removeById(tenantId, id);
      if (result.isSuccess())
        res.writeBody("", 204);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
