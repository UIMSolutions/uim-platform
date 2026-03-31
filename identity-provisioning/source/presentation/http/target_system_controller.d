module presentation.http.target_system_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_target_systems;
import application.dto;
import domain.entities.target_system;
import domain.types;
import presentation.http.json_utils;

class TargetSystemController
{
  private ManageTargetSystemsUseCase uc;

  this(ManageTargetSystemsUseCase uc)
  {
    this.uc = uc;
  }

  void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/target-systems", &handleCreate);
    router.get("/api/v1/target-systems", &handleList);
    router.get("/api/v1/target-systems/*", &handleGetById);
    router.put("/api/v1/target-systems/*", &handleUpdate);
    router.delete_("/api/v1/target-systems/*", &handleDelete);
    router.post("/api/v1/target-systems/activate/*", &handleActivate);
    router.post("/api/v1/target-systems/deactivate/*", &handleDeactivate);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateTargetSystemRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.systemType = parseSystemType(jsonStr(j, "systemType"));
      r.connectionConfig = jsonStr(j, "connectionConfig");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createTargetSystem(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listTargetSystems(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref s; items)
        arr ~= serializeSystem(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto sys = uc.getTargetSystem(id, tenantId);
      if (sys is null)
      {
        writeError(res, 404, "Target system not found");
        return;
      }
      res.writeJsonBody(serializeSystem(*sys), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateTargetSystemRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.connectionConfig = jsonStr(j, "connectionConfig");

      auto result = uc.updateTargetSystem(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Target system not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.activateSystem(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("active");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Target system not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deactivateSystem(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("inactive");
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteTargetSystem(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeSystem(ref const TargetSystem s)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["tenantId"] = Json(s.tenantId);
    j["name"] = Json(s.name);
    j["description"] = Json(s.description);
    j["systemType"] = Json(s.systemType.to!string);
    j["status"] = Json(s.status.to!string);
    j["connectionConfig"] = Json(s.connectionConfig);
    j["lastSyncAt"] = Json(s.lastSyncAt);
    j["createdBy"] = Json(s.createdBy);
    j["createdAt"] = Json(s.createdAt);
    j["updatedAt"] = Json(s.updatedAt);
    return j;
  }
}
