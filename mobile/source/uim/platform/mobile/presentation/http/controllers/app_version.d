/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.app_version;

import uim.platform.mobile.application.usecases.manage.app_versions;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

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
      r.buildNumber = jsonInt(j, "buildNumber");
      r.platform = j.getString("platform");
      r.releaseNotes = j.getString("releaseNotes");
      r.downloadUrl = j.getString("downloadUrl");
      r.sizeBytes = jsonLong(j, "sizeBytes");
      r.createdBy = j.getString("createdBy");
      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto results = uc.list(tenantId);
      auto resp = Json.emptyObject;
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("versionCode", item.versionCode)
          .set("platform", item.platform)
          .set("status", item.status);
      }
      resp["items"] = items;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.get(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.data.id);
        resp["tenantId"] = Json(result.data.tenantId);
        resp["appId"] = Json(result.data.appId);
        resp["versionCode"] = Json(result.data.versionCode);
        resp["buildNumber"] = Json(result.data.buildNumber);
        resp["platform"] = Json(result.data.platform);
        resp["releaseNotes"] = Json(result.data.releaseNotes);
        resp["downloadUrl"] = Json(result.data.downloadUrl);
        resp["sizeBytes"] = Json(result.data.sizeBytes);
        resp["createdBy"] = Json(result.data.createdBy);
        resp["status"] = Json(result.data.status);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateAppVersionRequest r;
      r.id = id;
      r.releaseNotes = j.getString("releaseNotes");
      r.downloadUrl = j.getString("downloadUrl");
      r.sizeBytes = jsonLong(j, "sizeBytes");
      r.status = j.getString("status");
      r.modifiedBy = j.getString("modifiedBy");
      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeBody("", 204);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
