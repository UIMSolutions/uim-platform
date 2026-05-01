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
      r.buildNumber = j.getInteger("buildNumber");
      r.platform = j.getString("platform");
      r.releaseNotes = j.getString("releaseNotes");
      r.downloadUrl = j.getString("downloadUrl");
      r.sizeBytes = jsonLong(j, "sizeBytes");
      r.createdBy = j.getString("createdBy");
      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App version created successfully");

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
      TenantId tenantId = req.getTenantId;
      auto results = uc.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("versionCode", item.versionCode)
          .set("platform", item.platform)
          .set("status", item.status);
      }

      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", Json(results.length))
        .set("message", Json("App versions retrieved successfully"));

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
        auto resp = Json.emptyObject
          .set("id", result.data.id)
          .set("tenantId", result.data.tenantId)
          .set("appId", result.data.appId)
          .set("versionCode", result.data.versionCode)
          .set("buildNumber", result.data.buildNumber)
          .set("platform", result.data.platform)
          .set("releaseNotes", result.data.releaseNotes)
          .set("downloadUrl", result.data.downloadUrl)
          .set("sizeBytes", result.data.sizeBytes)
          .set("createdBy", result.data.createdBy)
          .set("status", result.data.status)
          .set("message", "App version retrieved successfully");

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
      r.releaseNotes = j.getString("releaseNotes");
      r.downloadUrl = j.getString("downloadUrl");
      r.sizeBytes = jsonLong(j, "sizeBytes");
      r.status = j.getString("status");
      r.modifiedBy = j.getString("modifiedBy");
      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App version updated successfully");

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
