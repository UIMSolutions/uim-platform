/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.html_app;

import uim.platform.html_repository.application.usecases.manage.html_apps;
import uim.platform.html_repository.application.dto;
import uim.platform.html_repository.presentation.http.json_utils;

import uim.platform.htmls;

import std.conv : to;

class HtmlAppController : SAPController {
  private ManageHtmlAppsUseCase uc;

  this(ManageHtmlAppsUseCase uc) {
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
      CreateHtmlAppRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.namespace_ = j.getString("namespace");
      r.description = j.getString("description");
      r.spaceId = j.getString("spaceId");
      r.serviceInstanceId = j.getString("serviceInstanceId");
      r.visibility = j.getString("visibility");
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
      auto tenantId = req.getTenantId;
      auto items = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(e.id);
        obj["name"] = Json(e.name);
        obj["namespace"] = Json(e.namespace_);
        obj["visibility"] = Json(e.visibility);
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
      auto tenantId = req.getTenantId;
      if (id.length == 0) {
        writeError(res, 404, "App not found");
        return;
      }
      auto entry = uc.get_(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "App not found");
        return;
      }
      auto obj = Json.emptyObject;
      obj["id"] = Json(entry.id);
      obj["name"] = Json(entry.name);
      obj["namespace"] = Json(entry.namespace_);
      obj["description"] = Json(entry.description);
      obj["spaceId"] = Json(entry.spaceId);
      obj["serviceInstanceId"] = Json(entry.serviceInstanceId);
      obj["visibility"] = Json(entry.visibility);
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
      auto tenantId = req.getTenantId;
      if (id.length == 0) {
        writeError(res, 404, "App not found");
        return;
      }
      UpdateHtmlAppRequest r;
      r.id = id;
      r.tenantId = tenantId;
      r.description = j.getString("description");
      r.visibility = j.getString("visibility");
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
      auto tenantId = req.getTenantId;
      if (id.length == 0) {
        writeError(res, 404, "App not found");
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
