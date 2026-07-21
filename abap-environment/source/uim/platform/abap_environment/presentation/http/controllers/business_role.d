/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.business_role;
// import uim.platform.abap_environment.application.usecases.manage.business_roles;

// import uim.platform.abap_environment.domain.entities.business_role;

import uim.platform.abap_environment;

// mixin(ShowModule!());
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
class BusinessRoleController : ManageHttpController {
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
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    auto tenantId = TenantId(data.getString("tenantId"));
    auto r = CreateBusinessRoleRequest();
    r.tenantId = tenantId;
    r.instanceId = SystemInstanceId(data.getString("systemInstanceId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.roleType = data.getString("roleType");
    r.restrictionTypes = getStrings(data, "restrictionTypes");
    auto result = usecase.createBusinessRole(r);
    if (result.hasError())
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id)
      .set("message", "Business role created")
      .set("status", "created")
      .set("statusCode", 201);

    return successResponse("Business role created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    if (tenantId.isNull)
      return errorResponse("Tenant ID is required", 400);

    auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
    if (systemId.isNull)
      return errorResponse("System Instance ID is required in X-System-Id header", 400);

    auto roles = usecase.listBusinessRoles(tenantId, systemId);
    auto arr = roles.map!(r => r.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", arr)
      .set("totalCount", roles.length)
      .set("message", "Business roles fetched")
      .set("status", "success")
      .set("statusCode", 200);
    return successResponse("Business roles fetched successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    if (tenantId.isNull)
      return errorResponse("Tenant ID is required", 400);

    auto id = BusinessRoleId(precheck.id);
    if (id.isNull)
      return errorResponse("Business Role ID is required in the path", 400);

    auto role = usecase.getBusinessRole(tenantId, id);
    if (role.isNull)
      return errorResponse("Business role not found", 404);

    auto responseData = Json.emptyObject
      .set("entity", role.toJson)
      .set("message", "Business role fetched")
      .set("status", "success")
      .set("statusCode", 200);
    return successResponse("Business role fetched successfully", "Success", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = BusinessRoleId(precheck.id);
    if (id.isNull)
      return errorResponse("Business Role ID is required in the path", 400);

    auto data = precheck.data;
    auto tenantId = TenantId(data.getString("tenantId"));

    UpdateBusinessRoleRequest r;
    r.tenantId = tenantId;
    r.businessRoleId = id;
    r.description = data.getString("description");
    r.roleType = data.getString("roleType");
    r.restrictionTypes = getStrings(data, "restrictionTypes");

    auto result = usecase.updateBusinessRole(r);
    if (result.hasError())
      return errorResponse(result.message, 400);

    auto responsedata = Json.emptyObject
      .set("status", "updated")
      .set("message", "Business role updated")
      .set("statusCode", 200);
    return successResponse("Business role updated successfully", "Updated", 200, responsedata);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = BusinessRoleId(precheck.id);
    if (id.isNull)
      return errorResponse("Business Role ID is required in the path", 400);

    auto data = precheck.data;
    auto tenantId = TenantId(data.getString("tenantId"));
    auto result = usecase.deleteBusinessRole(tenantId, id);
    if (result.hasError())
      return errorResponse(result.message, 400);

    auto responsedata = Json.emptyObject
      .set("status", "deleted")
      .set("message", "Business role deleted")
      .set("statusCode", 200);
    return successResponse("Business role deleted successfully", "Deleted", 200, responsedata);
  }
}
/// 
unittest {
  auto usecase = new ManageBusinessRolesUseCase(new MemoryBusinessRoleRepository);
  auto controller = new BusinessRoleController(usecase);

  // Test createHandler with missing tenant ID
  auto createResponse = controller.createHandler(null);
  assert(createResponse.getString("status") == "error");
  assert(createResponse.getString("message") == "Request is required");

  // Test listHandler with missing tenant ID
  auto listResponse = controller.listHandler(null);
  assert(listResponse.getString("status") == "error");
  assert(listResponse.getString("message") == "Request is required");

  // Test getHandler with missing tenant ID
  auto getResponse = controller.getHandler(null);
  assert(getResponse.getString("status") == "error");
  assert(getResponse.getString("message") == "Request is required");

  // Test updateHandler with missing tenant ID
  auto updateResponse = controller.updateHandler(null);
  assert(updateResponse.getString("status") == "error");
  assert(updateResponse.getString("message") == "Request is required");

  // Test deleteHandler with missing tenant ID
  auto deleteResponse = controller.deleteHandler(null);
  assert(deleteResponse.getString("status") == "error");
  assert(deleteResponse.getString("message") == "Request is required");
}
