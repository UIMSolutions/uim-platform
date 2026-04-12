/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_route;

import uim.platform.html_repository.application.usecases.manage.app_routes;
import uim.platform.html_repository.application.dto;
import uim.platform.html_repository.presentation.http.json_utils;

import uim.platform.htmls;

import std.conv : to;

class AppRouteController : PlatformController {
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
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.pathPrefix = j.getString("pathPrefix");
      r.targetUrl = j.getString("targetUrl");
      r.description = j.getString("description");
      r.createdBy = j.getString("createdBy");

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
      TenantId tenantId = req.getTenantId;
      auto items = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items) {
        arr ~= Json.emptyObject
          .set("id", Json(e.id))
          .set("appId", Json(e.appId))
          .set("pathPrefix", Json(e.pathPrefix))
          .set("status", Json(e.status));
      }

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "Route not found");
        return;
      }
      auto entry = uc.get_(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Route not found");
        return;
      }
      
      auto response = Json.emptyObject
        .set("id", entry.id)
        .set("appId", entry.appId)
        .set("pathPrefix", entry.pathPrefix)
        .set("targetUrl", entry.targetUrl)
        .set("description", entry.description)
        .set("status", entry.status)
        .set("createdBy", entry.createdBy)
        .set("createdAt", entry.createdAt)
        .set("modifiedBy", entry.modifiedBy)
        .set("modifiedAt", entry.modifiedAt);

      res.writeJsonBody(response, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "Route not found");
        return;
      }
      UpdateAppRouteRequest r;
      r.id = id;
      r.tenantId = tenantId;
      r.description = j.getString("description");
      r.targetUrl = j.getString("targetUrl");
      r.modifiedBy = j.getString("modifiedBy");

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
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "Route not found");
        return;
      }
      auto result = uc.remove(tenantId, id);
      if (result.isSuccess())
        res.writeBody("", 204);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
