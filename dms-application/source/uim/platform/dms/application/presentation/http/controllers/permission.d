/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.permission;


// 
// 
// import uim.platform.dms.application.application.usecases.manage.permissions;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.permission;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class PermissionController : ManageController {
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

  protected void handleGrant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      auto r = CreatePermissionRequest();
      r.tenantId = tenantId;
      r.resourceId = data.getString("resourceId");
      r.resourceType = data.getString("resourceType").to!ResourceType;
      r.userId = UserId(data.getString("userId"));
      r.level = data.getString("level").to!PermissionLevel;
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = permissions.grantPermission(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject  
          .set("id", result.id)
          .set("message", "Permission granted");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleListByResource(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resourceId = precheck.id;
      auto tenantId = precheck.tenantId;
      auto resourceTypeStr = req.headers.get("X-Resource-Type", "document");
      auto resourceType = resourceTypeStr.to!ResourceType;

      auto items = permissions.listByResource(tenantId, resourceId, resourceType);
      auto arr = items.map!(item => item.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Permissions for resource retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleListByUser(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto userId = UserId(precheck.id);
      auto tenantId = precheck.tenantId;

      auto items = permissions.listByUser(tenantId, userId);
      auto arr = items.map!(item => item.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Permissions for user retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleCheckAccess(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      auto resourceId = data.getString("resourceId");
      auto resourceType = data.getString("resourceType").to!ResourceType;
      auto userId = UserId(data.getString("userId"));
      auto required = data.getString("requiredLevel").to!PermissionLevel;

      auto allowed = permissions.checkAccess(tenantId, resourceId, resourceType, userId, required);

      auto resp = Json.emptyObject
        .set("allowed", allowed ? Json(true) : Json(false))
        .set("resourceId", Json(resourceId))
        .set("resourceType", Json(resourceType.to!string))
        .set("userId", Json(userId.value))
        .set("requiredLevel", Json(required.to!string))
        .set("message", "Access check completed");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = PermissionId(precheck.id);
      auto j = req.json;
      auto r = UpdatePermissionRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.level = data.getString("level").to!PermissionLevel;

      auto result = permissions.updatePermission(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Permission updated");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = PermissionId(precheck.id);
      
      auto result = permissions.revokePermission(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Permission revoked");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
