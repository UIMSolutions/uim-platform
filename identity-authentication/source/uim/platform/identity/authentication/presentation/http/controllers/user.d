/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.controllers.user;
// 

// import uim.platform.identity.authentication.application.usecases.manage.users;
// import uim.platform.identity.authentication.application.dto;
// import uim.platform.identity.authentication.domain.entities.user;
// 
import uim.platform.identity.authentication;

// mixin(ShowModule!());
@safe:
/// HTTP controller for SCIM-like user management API.
class UserController : ManageHttpController {
  private ManageUsersUseCase useCase;

  this(ManageUsersUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/users", &handleCreate);
    router.get("/api/v1/users", &handleList);
    router.get("/api/v1/users/*", &handleGet);
    router.put("/api/v1/users/*", &handleUpdate);
    router.post("/api/v1/users/change-password", &handleChangePassword);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateUserRequest request;
    request.tenantId = tenantId;
    request.userName = data.getString("userName");
    request.email = data.getString("email");
    request.firstName = data.getString("firstName");
    request.lastName = data.getString("lastName");
    request.password = data.getString("password");
    request.phoneNumber = data.getString("phoneNumber");

    auto result = useCase.createUser(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject;
    response["id"] = result.userId;
    return successResponse("User created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    TenantId tenantId = req.params.get("tenantId", "");
    if (tenantId.isEmpty)
      tenantId = tenantId;

    auto users = useCase.listUsers(tenantId);
    auto response = Json.emptyObject;
    response["totalResults"] = users.length.toJson;
    response["resources"] = users.toJson;
    return successResponse("Users retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto tenantId = precheck.tenantId;
    auto path = req.requestURI;
    auto userId = precheck.id;

    auto user = useCase.getUser(tenantId, userId);
    if (user.isNull)
      return errorResponse("User not found", 404);

    auto response = user.toJson;
    // Remove sensitive field
    response.remove("passwordHash");
    response.remove("mfaSecret");
    return successResponse("User retrieved successfully", "Retrieved", 200, response);

  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = req.requestURI;
    auto userId = precheck.id;
    auto data = precheck.data;
    auto updateReq = UpdateUserRequest(tenantId, userId, data.getString("firstName"),
      data.getString("lastName"), data.getString("phoneNumber"));

    auto result = useCase.updateUser(updateReq);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("status", "updated");

    return successResponse("User updated successfully", "Updated", 200, resp);
  }

  protected Json changePasswordHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto result = useCase.changePassword(tenantId, data.getString("userId"),
      data.getString("oldPassword"), data.getString("newPassword"));

    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("status", "password_changed");

    return successResponse("Password changed successfully", "Updated", 200, resp);
  }

  mixin(HandleTemplate!("HandleChangePassword", "changePasswordHandler"));
}

private string extractIdFromPath(string path) {
  // import std.string : lastIndexOf;

  auto idx = path.lastIndexOf('/');
  if (idx >= 0 && idx + 1 < path.length)
    return path[idx + 1 .. $];
  return "";
}
