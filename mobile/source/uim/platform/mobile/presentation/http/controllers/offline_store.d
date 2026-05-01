/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.offline_store;

import uim.platform.mobile.application.usecases.manage.offline_stores;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class OfflineStoreController : PlatformController {
  private ManageOfflineStoresUseCase uc;

  this(ManageOfflineStoresUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/offline-stores", &handleCreate);
    router.get("/api/v1/offline-stores", &handleList);
    router.get("/api/v1/offline-stores/*", &handleGet);
    router.put("/api/v1/offline-stores/*", &handleUpdate);
    router.delete_("/api/v1/offline-stores/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateOfflineStoreRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.storeType = j.getString("storeType");
      r.syncPolicy = j.getString("syncPolicy");
      r.createdBy = j.getString("createdBy");
      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Offline store created successfully");

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
        .set("name", item.name)
        .set("storeType", item.storeType)
        .set("status", item.status);
      }

      auto resp = Json.emptyObject
        .set("items", items);
        
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
          .set("id", Json(result.data.id))
          .set("tenantId", Json(result.data.tenantId))
          .set("appId", Json(result.data.appId))
          .set("name", Json(result.data.name))
          .set("description", Json(result.data.description))
          .set("storeType", Json(result.data.storeType))
          .set("syncPolicy", Json(result.data.syncPolicy))
          .set("status", Json(result.data.status))
          .set("createdBy", Json(result.data.createdBy))
          .set("message", "Offline store retrieved successfully");

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
      UpdateOfflineStoreRequest r;
      r.id = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.syncPolicy = j.getString("syncPolicy");
      r.status = j.getString("status");
      r.modifiedBy = j.getString("modifiedBy");
      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Offline store updated successfully");

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
