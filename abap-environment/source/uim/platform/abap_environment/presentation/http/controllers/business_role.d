/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.business_role;
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
class BusinessRoleController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      return precheck;
    }

    auto data = precheck.data;
    auto tenantId = TenantId(data.getString("tenantId"));

    CreateBusinessRoleRequest r;
    r.tenantId = tenantId;
    r.systemInstanceId = SystemInstanceId(data.getString("systemInstanceId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.roleType = data.getString("roleType");
    r.restrictionTypes = getStrings(data, "restrictionTypes");

    auto result = usecase.createBusinessRole(r);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", result.message)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("message", "Business role created")
      .set("status", "created")
      .set("statusCode", 201);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    if (tenantId.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "Tenant ID is required")
        .set("statusCode", 400);
    }

    auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
    if (systemId.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "System Instance ID is required in X-System-Id header")
        .set("statusCode", 400);
    }

    auto roles = usecase.listBusinessRoles(tenantId, systemId);
    auto arr = roles.map!(r => r.toJson).array.toJson;

    return Json.emptyObject
      .set("items", arr)
      .set("totalCount", roles.length)
      .set("message", "Business roles fetched")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    if (tenantId.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "Tenant ID is required")
        .set("statusCode", 400);
    }

    auto id = BusinessRoleId(extractIdFromPath(req.requestURI));
    if (id.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "Business Role ID is required in the path")
        .set("statusCode", 400);
    }

    auto role = usecase.getBusinessRole(tenantId, id);
    if (role.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "Business role not found")
        .set("statusCode", 404);
    }

    return Json.emptyObject
      .set("entity", role.toJson)
      .set("message", "Business role fetched")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) {
      return precheck;
    }

    auto id = BusinessRoleId(extractIdFromPath(req.requestURI));
    if (id.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "Business Role ID is required in the path")
        .set("statusCode", 400);
    }

    auto data = precheck.data;
    auto tenantId = TenantId(data.getString("tenantId"));

    UpdateBusinessRoleRequest r;
    r.tenantId = tenantId;
    r.businessRoleId = id;
    r.description = data.getString("description");
    r.roleType = data.getString("roleType");
    r.restrictionTypes = getStrings(data, "restrictionTypes");

    auto result = usecase.updateBusinessRole(r);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", result.message)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("status", "updated")
      .set("message", "Business role updated")
      .set("statusCode", 200);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) {
      return precheck;
    }

    auto id = BusinessRoleId(extractIdFromPath(req.requestURI));
    if (id.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "Business Role ID is required in the path")
        .set("statusCode", 400);
    }

    auto data = precheck.data;
    auto tenantId = TenantId(data.getString("tenantId"));
    auto result = usecase.deleteBusinessRole(tenantId, id);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", result.message)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("status", "deleted")
      .set("message", "Business role deleted")
      .set("statusCode", 200);
  }
}
/// 
unittest {
  auto usecase = new ManageBusinessRolesUseCase(new MemoryBusinessRoleRepository);
  auto controller = new BusinessRoleController(usecase);

  // Test createHandler with missing tenant ID
  auto createResponse = controller.createHandler(null);
  assert(createResponse.getString("status") == "error");
  assert(createResponse.getString("message") == "Tenant ID is required");

  // Test listHandler with missing tenant ID
  auto listResponse = controller.listHandler(null);
  assert(listResponse.getString("status") == "error");
  assert(listResponse.getString("message") == "Tenant ID is required");

  // Test getHandler with missing tenant ID
  auto getResponse = controller.getHandler(null);
  assert(getResponse.getString("status") == "error");
  assert(getResponse.getString("message") == "Tenant ID is required");  

  // Test updateHandler with missing tenant ID
  auto updateResponse = controller.updateHandler(null);
  assert(updateResponse.getString("status") == "error");
  assert(updateResponse.getString("message") == "Tenant ID is required");

  // Test deleteHandler with missing tenant ID
  auto deleteResponse = controller.deleteHandler(null); 
  assert(deleteResponse.getString("status") == "error");
  assert(deleteResponse.getString("message") == "Tenant ID is required");
}
