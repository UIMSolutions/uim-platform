/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.service_instance;

import uim.platform.html_repository.application.usecases.manage.service_instances;
import uim.platform.html_repository.application.dto;
import uim.platform.html_repository.presentation.http.json_utils;

import uim.platform.htmls;

import std.conv : to;

class ServiceInstanceController : PlatformController {
  private ManageServiceInstancesUseCase uc;

  this(ManageServiceInstancesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/instances", &handleCreate);
    router.get("/api/v1/instances", &handleList);
    router.get("/api/v1/instances/*", &handleGet);
    router.put("/api/v1/instances/*", &handleUpdate);
    router.delete_("/api/v1/instances/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateServiceInstanceRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.spaceId = j.getString("spaceId");
      r.plan = j.getString("plan");
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
          .set("id", e.id)
          .set("name", e.name)
          .set("plan", e.plan)
          .set("status", e.status)
          .set("appCount", e.appCount);
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
      if (Id.isEmpty) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      auto entry = uc.getById(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      
      auto response = Json.emptyObject
        .set("id", entry.id)
        .set("name", entry.name)
        .set("description", entry.description)
        .set("spaceId", entry.spaceId)
        .set("plan", entry.plan)
        .set("status", entry.status)
        .set("appCount", entry.appCount)
        .set("createdBy", entry.createdBy)
        .set("createdAt", entry.createdAt)
        .set("modifiedBy", entry.modifiedBy)
        .set("updatedAt", entry.updatedAt);

      res.writeJsonBody(response, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (Id.isEmpty) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      UpdateServiceInstanceRequest r;
      r.id = id;
      r.tenantId = tenantId;
      r.description = j.getString("description");
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
      if (Id.isEmpty) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      auto result = uc.removeById(tenantId, id);
      if (result.isSuccess())
        res.writeBody("", 204);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
