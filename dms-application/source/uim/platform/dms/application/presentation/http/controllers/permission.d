/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.permission;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.dms.application.application.usecases.manage.permissions;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.permission;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class PermissionController : PlatformController {
  private ManagePermissionsUseCase permissions;

  this(ManagePermissionsUseCase permissions) {
    this.permissions = permissions;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/permissions", &handleGrant);
    router.get("/api/v1/permissions/resource/*", &handleListByResource);
    router.get("/api/v1/permissions/user/*", &handleListByUser);
    router.put("/api/v1/permissions/*", &handleUpdate);
    router.delete_("/api/v1/permissions/*", &handleRevoke);
    router.post("/api/v1/permissions/check", &handleCheckAccess);
  }

  private void handleGrant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreatePermissionRequest();
      r.tenantId = req.getTenantId;
      r.resourceId = j.getString("resourceId");
      r.resourceType = parseResourceType(j.getString("resourceType"));
      r.userId = j.getString("userId");
      r.level = parsePermissionLevel(j.getString("level"));
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = permissions.grantPermission(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject  
          .set("id", Json(result.id))
          .set("message", "Permission granted");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListByResource(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resourceId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto resourceTypeStr = req.headers.get("X-Resource-Type", "document");
      auto resourceType = parseResourceType(resourceTypeStr);

      auto items = permissions.listByResource(resourceId, resourceType, tenantId);
      auto arr = items.map!(item => item.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(items.length))
        .set("message", "Permissions for resource retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListByUser(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto userId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;

      auto items = permissions.listByUser(tenantId, userId);
      auto arr = items.map!(item => item.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(items.length))
        .set("message", "Permissions for user retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCheckAccess(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      TenantId tenantId = req.getTenantId;
      auto resourceId = j.getString("resourceId");
      auto resourceType = parseResourceType(j.getString("resourceType"));
      auto userId = j.getString("userId");
      auto required = parsePermissionLevel(j.getString("requiredLevel"));

      auto allowed = permissions.checkAccess(resourceId, resourceType, userId, required, tenantId);

      auto resp = Json.emptyObject
        .set("allowed", allowed ? Json(true) : Json(false))
        .set("resourceId", Json(resourceId))
        .set("userId", Json(userId))
        .set("requiredLevel", Json(required.to!string))
        .set("message", "Access check completed");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdatePermissionRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.level = parsePermissionLevel(j.getString("level"));

      auto result = permissions.updatePermission(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Permission updated");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = permissions.revokePermission(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Permission revoked");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
