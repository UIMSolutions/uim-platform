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
class PermissionController : ManageHttpController {
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

  protected Json grantHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CreatePermissionRequest();
    r.tenantId = tenantId;
    r.resourceId = data.getString("resourceId");
    r.resourceType = data.getString("resourceType").to!ResourceType;
    r.userId = UserId(data.getString("userId"));
    r.level = data.getString("level").to!PermissionLevel;
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = permissions.grantPermission(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);

    return successResponse("Permission granted successfully", "Granted", 201, responseData);
  }

  mixin(HandleTemplate!("handleGrant", "grantHandler"));

  protected Json listByResourceHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto resourceId = precheck.id;
    auto tenantId = precheck.tenantId;
    auto resourceTypeStr = req.headers.get("X-Resource-Type", "document");
    auto resourceType = resourceTypeStr.to!ResourceType;

    auto items = permissions.listByResource(tenantId, resourceId, resourceType);
    auto arr = items.map!(item => item.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Permissions for resource retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleListByResource", "listByResourceHandler"));

  protected Json listByUserHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto userId = UserId(precheck.id);
    auto tenantId = precheck.tenantId;

    auto items = permissions.listByUser(tenantId, userId);
    auto arr = items.map!(item => item.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Permissions for user retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleListByUser", "listByUserHandler"));

  protected Json checkAccessHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
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
      .set("requiredLevel", Json(required.to!string));

    return successResponse("Access check completed", "Checked", 200, resp);
  }

  mixin(HandleTemplate!("handleCheckAccess", "checkAccessHandler"));

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PermissionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid permission ID", 400);

    auto data = precheck.data;
    auto r = UpdatePermissionRequest();
    r.permissionId = id;
    r.tenantId = tenantId;
    r.level = data.getString("level").to!PermissionLevel;

    auto result = permissions.updatePermission(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Permission updated successfully", "Updated", 200, responseData);
  }

  protected Json revokeHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PermissionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid permission ID", 400);

    auto result = permissions.revokePermission(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("deleted", true);

    return successResponse("Permission revoked successfully", "Revoked", 200, resp);
  }

  mixin(HandleTemplate!("handleRevoke", "revokeHandler"));

}
