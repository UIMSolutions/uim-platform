/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_route;

import uim.platform.html_repository.application.usecases.manage.app_routes;
import uim.platform.html_repository.application.dto;
import uim.platform.html_repository.presentation.http.json_utils;

import uim.platform.html_repository;

import std.conv : to;

class AppRouteController : SAPController {
  private ManageAppRoutesUseCase uc;

  this(ManageAppRoutesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/routes", &handleCreate);
    router.get("/api/v1/routes", &handleList);
    router.get("/api/v1/routes/*", &handleGet);
    router.put("/api/v1/routes/*", &handleUpdate);
    router.delete_("/api/v1/routes/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAppRouteRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.appId = jsonStr(j, "appId");
      r.pathPrefix = jsonStr(j, "pathPrefix");
      r.targetUrl = jsonStr(j, "targetUrl");
      r.description = jsonStr(j, "description");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = uc.create(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(e.id);
        obj["appId"] = Json(e.appId);
        obj["pathPrefix"] = Json(e.pathPrefix);
        obj["status"] = Json(e.status);
        arr ~= obj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      if (id.length == 0) {
        writeError(res, 404, "Route not found");
        return;
      }
      auto entry = uc.get_(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Route not found");
        return;
      }
      auto obj = Json.emptyObject;
      obj["id"] = Json(entry.id);
      obj["appId"] = Json(entry.appId);
      obj["pathPrefix"] = Json(entry.pathPrefix);
      obj["targetUrl"] = Json(entry.targetUrl);
      obj["description"] = Json(entry.description);
      obj["status"] = Json(entry.status);
      obj["createdBy"] = Json(entry.createdBy);
      obj["createdAt"] = Json(entry.createdAt);
      obj["modifiedBy"] = Json(entry.modifiedBy);
      obj["modifiedAt"] = Json(entry.modifiedAt);
      res.writeJsonBody(obj, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      if (id.length == 0) {
        writeError(res, 404, "Route not found");
        return;
      }
      UpdateAppRouteRequest r;
      r.id = id;
      r.tenantId = tenantId;
      r.description = jsonStr(j, "description");
      r.targetUrl = jsonStr(j, "targetUrl");
      r.modifiedBy = jsonStr(j, "modifiedBy");

      auto result = uc.update(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      if (id.length == 0) {
        writeError(res, 404, "Route not found");
        return;
      }
      auto result = uc.remove(id, tenantId);
      if (result.isSuccess())
        res.writeBody("", 204);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
