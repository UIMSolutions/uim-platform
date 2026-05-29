/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.role;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class RoleController : ManageController {
  private ManageRolesUseCase usecase;

  this(ManageRolesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/roles", &handleCreate);
    router.get("/api/v1/roles", &handleList);
    router.get("/api/v1/roles/*", &handleGet);
    router.put("/api/v1/roles/*", &handleUpdate);
    router.delete_("/api/v1/roles/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateRoleRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.appId = data.getString("appId");

    auto srArr = j["scopeReferences"];
    if (srArr.isArray)
      foreach (v; srArr.byValue)
        r.scopeReferences ~= v.get!string;

    auto result = usecase.createRole(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Role created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto roles = usecase.listRoles(tenantId);
    auto list = roles.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Role list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = RoleId(extractIdFromPath(req));
    if (id.isNull)
      return errorResponse("Invalid role ID", 400);

    auto role = usecase.getRole(tenantId, id);
    if (role.isNull)
      return errorResponse("Role not found", 404);

    auto responseData = role.toJson();
    return successResponse("Role retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = RoleId(extractIdFromPath(req));
    if (id.isNull)
      return errorResponse("Invalid role ID", 400);

    auto data = precheck.data;
    UpdateRoleRequest r;
    r.tenantId = tenantId;
    r.roleId = id;
    r.description = data.getString("description");

    auto srArr = j["scopeReferences"];
    if (srArr.isArray)
      foreach (v; srArr.byValue)
        r.scopeReferences ~= v.get!string;

    auto result = usecase.updateRole(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Role updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = RoleId(extractIdFromPath(req));
    if (id.isNull)
      return errorResponse("Invalid role ID", 400);

    auto result = usecase.deleteRole(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Role deleted successfully", "Deleted", 200, responseData);
  }
}
