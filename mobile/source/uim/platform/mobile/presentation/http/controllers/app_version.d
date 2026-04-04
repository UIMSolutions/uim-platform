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

class AppVersionController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.appId = jsonStr(j, "appId");
      r.versionCode = jsonStr(j, "versionCode");
      r.buildNumber = jsonInt(j, "buildNumber");
      r.platform = jsonStr(j, "platform");
      r.releaseNotes = jsonStr(j, "releaseNotes");
      r.downloadUrl = jsonStr(j, "downloadUrl");
      r.sizeBytes = jsonLong(j, "sizeBytes");
      r.createdBy = jsonStr(j, "createdBy");
      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto results = uc.list(tenantId);
      auto resp = Json.emptyObject;
      auto items = Json.emptyArray;
      foreach (item; results) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(item.id);
        obj["appId"] = Json(item.appId);
        obj["versionCode"] = Json(item.versionCode);
        obj["platform"] = Json(item.platform);
        obj["status"] = Json(item.status);
        items ~= obj;
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
      } else {
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
      r.releaseNotes = jsonStr(j, "releaseNotes");
      r.downloadUrl = jsonStr(j, "downloadUrl");
      r.sizeBytes = jsonLong(j, "sizeBytes");
      r.status = jsonStr(j, "status");
      r.modifiedBy = jsonStr(j, "modifiedBy");
      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
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
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
