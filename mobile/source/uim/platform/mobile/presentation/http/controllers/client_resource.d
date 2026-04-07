/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.client_resource;

import uim.platform.mobile.application.usecases.manage.client_resources;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class ClientResourceController : SAPController {
  private ManageClientResourcesUseCase uc;

  this(ManageClientResourcesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/resources", &handleCreate);
    router.get("/api/v1/resources", &handleList);
    router.get("/api/v1/resources/*", &handleGet);
    router.put("/api/v1/resources/*", &handleUpdate);
    router.delete_("/api/v1/resources/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateClientResourceRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.appId = jsonStr(j, "appId");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.type = jsonStr(j, "type");
      r.contentType = jsonStr(j, "contentType");
      r.data = jsonStr(j, "data");
      r.createdBy = jsonStr(j, "createdBy");
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto results = uc.list(tenantId);
      auto resp = Json.emptyObject;
      auto items = Json.emptyArray;
      foreach (item; results) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(item.id);
        obj["appId"] = Json(item.appId);
        obj["name"] = Json(item.name);
        obj["type"] = Json(item.type);
        obj["contentType"] = Json(item.contentType);
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
        resp["type"] = Json(result.data.type);
        resp["contentType"] = Json(result.data.contentType);
        resp["data"] = Json(result.data.data);
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
      UpdateClientResourceRequest r;
      r.id = id;
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.type = jsonStr(j, "type");
      r.contentType = jsonStr(j, "contentType");
      r.data = jsonStr(j, "data");
      r.modifiedBy = jsonStr(j, "modifiedBy");
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
