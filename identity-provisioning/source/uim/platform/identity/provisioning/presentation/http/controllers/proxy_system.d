/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module presentation.http.proxy_system;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_proxy_systems;
import application.dto;
import domain.entities.proxy_system;
import domain.types;
import presentation.http.json_utils;

class ProxySystemController {
  private ManageProxySystemsUseCase uc;

  this(ManageProxySystemsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/proxy-systems", &handleCreate);
    router.get("/api/v1/proxy-systems", &handleList);
    router.get("/api/v1/proxy-systems/*", &handleGetById);
    router.put("/api/v1/proxy-systems/*", &handleUpdate);
    router.delete_("/api/v1/proxy-systems/*", &handleDelete);
    router.post("/api/v1/proxy-systems/activate/*", &handleActivate);
    router.post("/api/v1/proxy-systems/deactivate/*", &handleDeactivate);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateProxySystemRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.systemType = parseSystemType(j.getString("systemType"));
      r.connectionConfig = j.getString("connectionConfig");
      r.sourceSystemId = j.getString("sourceSystemId");
      r.targetSystemId = j.getString("targetSystemId");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createProxySystem(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listProxySystems(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref s; items)
        arr ~= serializeSystem(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto sys = uc.getProxySystem(id, tenantId);
      if (sys is null) {
        writeError(res, 404, "Proxy system not found");
        return;
      }
      res.writeJsonBody(serializeSystem(*sys), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateProxySystemRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.connectionConfig = j.getString("connectionConfig");

      auto result = uc.updateProxySystem(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Proxy system not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.activateSystem(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("active");
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Proxy system not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deactivateSystem(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("inactive");
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteProxySystem(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeSystem(ref const ProxySystem s) {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["tenantId"] = Json(s.tenantId);
    j["name"] = Json(s.name);
    j["description"] = Json(s.description);
    j["systemType"] = Json(s.systemType.to!string);
    j["status"] = Json(s.status.to!string);
    j["connectionConfig"] = Json(s.connectionConfig);
    j["sourceSystemId"] = Json(s.sourceSystemId);
    j["targetSystemId"] = Json(s.targetSystemId);
    j["createdBy"] = Json(s.createdBy);
    j["createdAt"] = Json(s.createdAt);
    j["updatedAt"] = Json(s.updatedAt);
    return j;
  }
}
