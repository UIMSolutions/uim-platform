/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.business_user;

// 
// 
// import uim.platform.abap_environment.application.usecases.manage.business_users;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.business_user;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
class BusinessUserController : ManageController {
  private ManageBusinessUsersUseCase usecase;

  this(ManageBusinessUsersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-users", &handleCreate);
    router.get("/api/v1/business-users", &handleList);
    router.get("/api/v1/business-users/*", &handleGet);
    router.put("/api/v1/business-users/*", &handleUpdate);
    router.delete_("/api/v1/business-users/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

    auto users = usecase.listBusinessUsers(tenantId, systemId);
    auto arr = users.map!(user => user.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", users.length);

    return successResponse("Business user list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateBusinessUserRequest r;
    r.tenantId = tenantId;
    r.systemInstanceId = SystemInstanceId(data.getString("systemInstanceId"));
    r.username = data.getString("username");
    r.firstName = data.getString("firstName");
    r.lastName = data.getString("lastName");
    r.email = data.getString("email");
    r.roleIds = data.getStrings("roleIds");

    auto result = usecase.createBusinessUser(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business user created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = BusinessUserId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid business user ID", 400);

    auto user = usecase.getBusinessUser(tenantId, id);
    if (user.isNull)
      return errorResponse("Business user not found", 404);

    auto responseData = user.toJson();
    return successResponse("Business user retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto id = BusinessUserId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid business user ID", 400);

    UpdateBusinessUserRequest r;
    r.tenantId = tenantId;
    r.businessUserId = id;
    r.firstName = data.getString("firstName");
    r.lastName = data.getString("lastName");
    r.email = data.getString("email");
    r.status = data.getString("status");
    r.roleIds = getStrings(data, "roleIds");

    auto result = usecase.updateBusinessUser(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", id);
    return successResponse("Business user updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = BusinessUserId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid business user ID", 400);

    auto result = usecase.deleteBusinessUser(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business user deleted successfully", "Deleted", 200, responseData);
  }
}
