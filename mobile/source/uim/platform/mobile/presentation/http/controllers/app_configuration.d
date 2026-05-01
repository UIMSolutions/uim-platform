/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.app_configuration;

import uim.platform.mobile.application.usecases.manage.app_configurations;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class AppConfigurationController : PlatformController {
  private ManageAppConfigurationsUseCase uc;

  this(ManageAppConfigurationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/configurations", &handleCreate);
    router.get("/api/v1/configurations", &handleList);
    router.get("/api/v1/configurations/*", &handleGet);
    router.put("/api/v1/configurations/*", &handleUpdate);
    router.delete_("/api/v1/configurations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAppConfigurationRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.key = j.getString("key");
      r.value = j.getString("value");
      r.description = j.getString("description");
      r.isSecret = j.getBoolean("isSecret");
      r.platform = j.getString("platform");
      r.createdBy = j.getString("createdBy");
      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration created successfully");

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
          .set("key", item.key)
          .set("platform", item.platform)
          .set("status", item.status);
      }

      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", results.length)
        .set("message", "App configurations retrieved successfully");
        
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
          .set("key", result.data.key)
          .set("value", result.data.value)
          .set("description", result.data.description)
          .set("isSecret", result.data.isSecret)
          .set("platform", result.data.platform)
          .set("createdBy", result.data.createdBy)
          .set("message", "App configuration retrieved successfully");

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
      UpdateAppConfigurationRequest r;
      r.id = id;
      r.value = j.getString("value");
      r.description = j.getString("description");
      r.isSecret = j.getBoolean("isSecret");
      r.platform = j.getString("platform");
      r.modifiedBy = j.getString("modifiedBy");
      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration updated successfully");

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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration deleted successfully");
          
        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
