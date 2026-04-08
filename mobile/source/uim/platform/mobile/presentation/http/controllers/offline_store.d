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

class OfflineStoreController : SAPController {
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
      auto tenantId = req.getTenantId;
      auto results = uc.list(tenantId);
      auto resp = Json.emptyObject;
      auto items = Json.emptyArray;
      foreach (item; results) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(item.id);
        obj["appId"] = Json(item.appId);
        obj["name"] = Json(item.name);
        obj["storeType"] = Json(item.storeType);
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
        resp["name"] = Json(result.data.name);
        resp["description"] = Json(result.data.description);
        resp["storeType"] = Json(result.data.storeType);
        resp["syncPolicy"] = Json(result.data.syncPolicy);
        resp["status"] = Json(result.data.status);
        resp["createdBy"] = Json(result.data.createdBy);
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
      UpdateOfflineStoreRequest r;
      r.id = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.syncPolicy = j.getString("syncPolicy");
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
