/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.mobile_app;

import uim.platform.mobile.application.usecases.manage.mobile_apps;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class MobileAppController : SAPController {
  private ManageMobileAppsUseCase uc;

  this(ManageMobileAppsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/apps", &handleCreate);
    router.get("/api/v1/apps", &handleList);
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateMobileAppRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.bundleId = jsonStr(j, "bundleId");
      r.platform = jsonStr(j, "platform");
      r.securityConfig = jsonStr(j, "securityConfig");
      r.authProvider = jsonStr(j, "authProvider");
      r.pushEnabled = jsonBool(j, "pushEnabled");
      r.offlineEnabled = jsonBool(j, "offlineEnabled");
      r.iconUrl = jsonStr(j, "iconUrl");
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
        obj["name"] = Json(item.name);
        obj["bundleId"] = Json(item.bundleId);
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
        resp["name"] = Json(result.data.name);
        resp["description"] = Json(result.data.description);
        resp["bundleId"] = Json(result.data.bundleId);
        resp["platform"] = Json(result.data.platform);
        resp["securityConfig"] = Json(result.data.securityConfig);
        resp["authProvider"] = Json(result.data.authProvider);
        resp["pushEnabled"] = Json(result.data.pushEnabled);
        resp["offlineEnabled"] = Json(result.data.offlineEnabled);
        resp["iconUrl"] = Json(result.data.iconUrl);
        resp["status"] = Json(result.data.status);
        resp["createdBy"] = Json(result.data.createdBy);
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
      UpdateMobileAppRequest r;
      r.id = id;
      r.description = jsonStr(j, "description");
      r.securityConfig = jsonStr(j, "securityConfig");
      r.authProvider = jsonStr(j, "authProvider");
      r.status = jsonStr(j, "status");
      r.pushEnabled = jsonBool(j, "pushEnabled");
      r.offlineEnabled = jsonBool(j, "offlineEnabled");
      r.iconUrl = jsonStr(j, "iconUrl");
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
