/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.role;


// import uim.platform.portal.application.usecases.manage.roles;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.role;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class RoleController : ManageHttpController {
  private ManageRolesUseCase useCase;

  this(ManageRolesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/roles", &handleCreate);
    router.get("/api/v1/roles", &handleList);
    router.get("/api/v1/roles/*", &handleGet);
    router.put("/api/v1/roles/*", &handleUpdate);
    router.delete_("/api/v1/roles/*", &handleDelete);
    router.post("/api/v1/roles/assign", &handleAssign);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreateRoleRequest(req.headers.get("X-Tenant-Id", ""),
        data.getString("name"), data.getString("description"),
        jsonEnum!RoleScope(j, "scope", RoleScope.site),);

      auto result = useCase.createRole(createReq);
      if (result.hasError())
        return errorResponse("", 0);

        auto response = Json.emptyObject;
        response["id"] = Json(result.roleId);

        return successResponse("", "", 0, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto roles = useCase.listRoles(tenantId);
      auto response = Json.emptyObject
      .set("totalResults", Json(roles.length))
      .set("resources", roles.map!(role => role.toJson).array.toJson);

      return successResponse("", "", 0, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto roleId = precheck.id;
      auto role = useCase.getRole(roleId);
      if (role.isNull)
        return errorResponse("", 0);

    return successResponse("", "", 0, role.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto roleId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateRoleRequest(roleId, data.getString("name"),
        data.getString("description"),);

      auto result = useCase.updateRole(updateReq);
      if (result.isNull) 
      return errorResponse("", 0);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("", "", 0, responseData);
  }

  protected void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto assignReq = AssignRoleRequest(data.getString("roleId"), getStrings(j,
          "userIds"), data.getStrings("groupIds"),);

      auto error = useCase.assignRole(assignReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto roleId = precheck.id;
      auto error = useCase.deleteRole(roleId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }
}
