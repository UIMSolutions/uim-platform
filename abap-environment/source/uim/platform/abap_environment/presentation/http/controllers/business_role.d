/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.business_role;




// 
// 
// import uim.platform.abap_environment.application.usecases.manage.business_roles;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.business_role;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

/**
  * HTTP controller for managing business roles in the ABAP environment.
  * Provides endpoints for creating, listing, retrieving, updating, and deleting business roles.
  *
  * Endpoints:
  * - POST /api/v1/business-roles: Create a new business role.
  * - GET /api/v1/business-roles: List all business roles for a system instance.
  * - GET /api/v1/business-roles/{id}: Get details of a specific business role by ID.
  * - PUT /api/v1/business-roles/{id}: Update an existing business role.
  * - DELETE /api/v1/business-roles/{id}: Delete a business role.
  * Each endpoint expects and returns JSON data, and uses standard HTTP status codes to indicate success or failure.
  */
class BusinessRoleController : PlatformController {
  private ManageBusinessRolesUseCase usecase;

  this(ManageBusinessRolesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-roles", &handleCreate);
    router.get("/api/v1/business-roles", &handleList);
    router.get("/api/v1/business-roles/*", &handleGet);
    router.put("/api/v1/business-roles/*", &handleUpdate);
    router.delete_("/api/v1/business-roles/*", &handleDelete);
  }

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto j = req.json;
      CreateBusinessRoleRequest r;
      r.tenantId = tenantId;
      r.systemInstanceId = j.getString("systemInstanceId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.roleType = j.getString("roleType");
      r.restrictionTypes = getStrings(j, "restrictionTypes");

      auto result = usecase.createRole(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Business role created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

      auto roles = usecase.listRoles(tenantId, systemId);
      auto arr = roles.map!(r => r.toJson).array.toJson;

      auto response = Json.emptyObject
        .set("items", arr)
        .set("totalCount", roles.length)
        .set("message", "Business roles fetched");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = BusinessRoleId(extractIdFromPath(req.requestURI));

      auto role = usecase.getRole(tenantId, id);
      if (role.isNull) {
        writeError(res, 404, "Business role not found");
        return;
      }

      auto response = role.toJson
        .set("message", "Business role fetched"); 
        
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = BusinessRoleId(extractIdFromPath(req.requestURI));

      auto j = req.json;
      UpdateBusinessRoleRequest r;
      r.tenantId = tenantId;
      r.businessRoleId = id;
      r.description = j.getString("description");
      r.roleType = j.getString("roleType");
      r.restrictionTypes = getStrings(j, "restrictionTypes");

      auto result = usecase.updateRole(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "Business role updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = BusinessRoleId(extractIdFromPath(req.requestURI));

      auto result = usecase.deleteRole(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Business role deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
