/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.device_registration;

import uim.platform.mobile.application.usecases.manage.device_registrations;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class DeviceRegistrationController : PlatformController {
  private ManageDeviceRegistrationsUseCase uc;

  this(ManageDeviceRegistrationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/devices", &handleRegister);
    router.get("/api/v1/devices", &handleList);
    router.get("/api/v1/devices/*", &handleGet);
    router.put("/api/v1/devices/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/devices/*", &handleDelete);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RegisterDeviceRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.deviceModel = j.getString("deviceModel");
      r.osVersion = j.getString("osVersion");
      r.appVersion = j.getString("appVersion");
      r.platform = j.getString("platform");
      r.userId = j.getString("userId");
      r.deviceToken = j.getString("deviceToken");
      auto result = uc.register(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id));

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
          .set("deviceModel", item.deviceModel)
          .set("platform", item.platform)
          .set("status", item.status);
      }
      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", results.length)
        .set("message", "Device registrations retrieved successfully");

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
          .set("deviceModel", result.data.deviceModel)
          .set("osVersion", result.data.osVersion)
          .set("appVersion", result.data.appVersion)
          .set("platform", result.data.platform)
          .set("userId", result.data.userId)
          .set("deviceToken", result.data.deviceToken)
          .set("status", result.data.status);

        res.writeJsonBody(resp, 200); 
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      auto status = j.getString("status");
      auto result = uc.updateStatus(id, status);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
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
      auto result = uc.removeById(id);
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
