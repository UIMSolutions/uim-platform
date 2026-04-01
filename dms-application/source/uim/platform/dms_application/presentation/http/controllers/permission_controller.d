module uim.platform.dms-application.presentation.http.controllers.permission_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_permissions;
import application.dto;
import domain.entities.permission;
import domain.types;
import uim.platform.dms-application.presentation.http.json_utils;

class PermissionController
{
  private ManagePermissionsUseCase uc;

  this(ManagePermissionsUseCase uc)
  {
    this.uc = uc;
  }

  void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/permissions", &handleGrant);
    router.get("/api/v1/permissions/resource/*", &handleListByResource);
    router.get("/api/v1/permissions/user/*", &handleListByUser);
    router.put("/api/v1/permissions/*", &handleUpdate);
    router.delete_("/api/v1/permissions/*", &handleRevoke);
    router.post("/api/v1/permissions/check", &handleCheckAccess);
  }

  private void handleGrant(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreatePermissionRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.resourceId = j.getString("resourceId");
      r.resourceType = parseResourceType(jsonStr(j, "resourceType"));
      r.userId = j.getString("userId");
      r.level = parsePermissionLevel(jsonStr(j, "level"));
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.grantPermission(r);
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

  private void handleListByResource(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto resourceId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto resourceTypeStr = req.headers.get("X-Resource-Type", "document");
      auto resourceType = parseResourceType(resourceTypeStr);

      auto items = uc.listByResource(resourceId, resourceType, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref p; items)
        arr ~= serializePerm(p);

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

  private void handleListByUser(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto userId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listByUser(userId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref p; items)
        arr ~= serializePerm(p);

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

  private void handleCheckAccess(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto resourceId = j.getString("resourceId");
      auto resourceType = parseResourceType(jsonStr(j, "resourceType"));
      auto userId = j.getString("userId");
      auto required = parsePermissionLevel(jsonStr(j, "requiredLevel"));

      auto allowed = uc.checkAccess(resourceId, resourceType, userId, required, tenantId);

      auto resp = Json.emptyObject;
      resp["allowed"] = allowed ? Json(true) : Json(false);
      resp["resourceId"] = Json(resourceId);
      resp["userId"] = Json(userId);
      resp["requiredLevel"] = Json(required.to!string);
      res.writeJsonBody(resp, 200);
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
      auto r = UpdatePermissionRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.level = parsePermissionLevel(jsonStr(j, "level"));

      auto result = uc.updatePermission(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.revokePermission(id, tenantId);
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

  private static Json serializePerm(ref const Permission p)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(p.id);
    j["tenantId"] = Json(p.tenantId);
    j["resourceId"] = Json(p.resourceId);
    j["resourceType"] = Json(p.resourceType.to!string);
    j["userId"] = Json(p.userId);
    j["level"] = Json(p.level.to!string);
    j["createdBy"] = Json(p.createdBy);
    j["createdAt"] = Json(p.createdAt);
    return j;
  }
}
