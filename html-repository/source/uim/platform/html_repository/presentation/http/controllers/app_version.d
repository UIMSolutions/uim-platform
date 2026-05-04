/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_version;

// import uim.platform.html_repository.application.usecases.manage.app_versions;
// import uim.platform.html_repository.application.dto;

// import uim.platform.htmls;

// import std.conv : to;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppVersionController : PlatformController {
  private ManageAppVersionsUseCase uc;

  this(ManageAppVersionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/versions", &handleCreate);
    router.get("/api/v1/versions", &handleList);
    router.get("/api/v1/versions/*", &handleGet);
    router.put("/api/v1/versions/*", &handleUpdate);
    router.delete_("/api/v1/versions/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAppVersionRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.versionCode = j.getString("versionCode");
      r.description = j.getString("description");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = uc.create(r);
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
      auto appId = getString(req.json, "appId");
      if (appId.isEmpty)
        appId = req.headers.get("X-App-Id", "");
      auto items = uc.listByApp(appId);

      auto arr = Json.emptyArray;
      foreach (e; items) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(e.id);
        obj["appId"] = Json(e.appId);
        obj["versionCode"] = Json(e.versionCode);
        obj["status"] = Json(e.status);
        obj["fileCount"] = Json(e.fileCount);
        arr ~= obj;
      }

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "Version not found");
        return;
      }
      auto entry = uc.getById(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Version not found");
        return;
      }
      auto obj = Json.emptyObject
        .set("id", entry.id)
        .set("appId", entry.appId)
        .set("versionCode", entry.versionCode)
        .set("description", entry.description)
        .set("status", entry.status)
        .set("fileCount", entry.fileCount)
        .set("createdBy", entry.createdBy)
        .set("createdAt", entry.createdAt)
        .set("updatedAt", entry.updatedAt);

      res.writeJsonBody(obj, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "Version not found");
        return;
      }
      UpdateAppVersionRequest r;
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = uc.update(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", id);
          
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
        writeError(res, 404, "Version not found");
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
