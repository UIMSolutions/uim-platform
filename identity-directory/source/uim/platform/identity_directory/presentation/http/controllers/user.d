/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.http.controllers.user;

// import uim.platform.identity_directory.application.usecases.manage.users;

// import uim.platform.identity_directory.domain.entities.user;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for SCIM 2.0 user management.
class UserController : ManageHttpController {
  private ManageUsersUseCase useCase;

  this(ManageUsersUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/scim/Users", &handleCreate);
    router.get("/scim/Users", &handleList);
    router.get("/scim/Users/*", &handleGet);
    router.put("/scim/Users/*", &handleUpdate);
    router.delete_("/scim/Users/*", &handleDelete);
    router.post("/scim/Users/change-password", &handleChangePassword);
    router.get("/scim/Users/search", &handleSearch);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreateUserRequest();
    createReq.tenantId = tenantId;
    createReq.externalId = data.getString("externalId");
    createReq.userName = data.getString("userName");
    createReq.displayName = data.getString("displayName");
    createReq.userType = data.getString("userType");
    createReq.preferredLanguage = data.getString("preferredLanguage");
    createReq.locale = data.getString("locale");
    createReq.timezone = data.getString("timezone");
    createReq.password = data.getString("password");
    // createReq.emails = parseEmails(data);
    // createReq.phoneNumbers = parsePhoneNumbers(data);
    createReq.addresses = data.toAddresses;

    auto result = useCase.createUser(createReq);
    if (result.hasError)
      return scimErrorResponse(result.message, 409);

    auto response = Json.emptyObject;
    response["id"] = result.userId.value;
    response["schemas"] = Json.emptyArray;
    response["schemas"] ~= Json("urn:ietf:params:scim:schemas:core:2.0:IDUser");
    return successResponse("User created successfully", "Created", 201, response);
    // writeScimError(res, 409, result.message);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto users = useCase.listUsers(tenantId);
    auto response = Json.emptyObject;
    response["schemas"] = Json.emptyArray;
    response["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:ListResponse");
    response["totalResults"] = Json(users.length);
    response["startIndex"] = Json(1L);
    response["itemsPerPage"] = Json(users.length);
    response["Resources"] = users.map!(u => u.toJson).array.toJson;

    return successResponse("Users retrieved successfully", "", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto userId = precheck.id;
    auto user = useCase.getUser(tenantId, userId);
    if (user.isNull)
      return scimErrorResponse("User not found", 404);

    auto response = user.toJson;
    return successResponse("User retrieved successfully", "", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto userId = precheck.id;
    auto data = precheck.data;
    auto request = UpdateUserRequest();
    request.tenantId = tenantId;
    request.userId = userId;
    // request.externalId = data.getString("externalId");
    // request.userName = data.getString("userName");
    request.displayName = data.getString("displayName");
    request.userType = data.getString("userType");
    request.preferredLanguage = data.getString("preferredLanguage");
    request.locale = data.getString("locale");
    request.timezone = data.getString("timezone");
    request.active = data.getBoolean("active", true);
    request.emails = parseEmails(data);
    request.phoneNumbers = parsePhoneNumbers(data);
    request.addresses = data.toAddresses;
    request.extendedAttributes = []; // extendedAttributes

    auto result = useCase.updateUser(request);
    if (result.error)
      return errorResponse(result.message, 404);
    // writeScimError(res, 404, result.message);

    auto response = Json.emptyObject.set("id", userId);
    response["schemas"] = Json.emptyArray;
    response["schemas"] ~= Json("urn:ietf:params:scim:schemas:core:2.0:IDUser");
    return successResponse("User updated successfully", "", 200, response);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = UserId(precheck.id);

    auto result = useCase.deleteUser(tenantId, id);
    if (result.error)
      return errorResponse(result.message, 404);
      // writeScimError(res, 404, result.message);

    return successResponse("User deleted successfully", "", 200, Json.emptyObject);
  }

  protected Json changePasswordHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = UserId(precheck.id);

    auto data = precheck.data;
    auto result = useCase.changePassword(tenantId, id,
      data.getString("currentPassword"), data.getString("newPassword"));
    if (result.error)
      return errorResponse(result.message, 400);
      // return scimErrorResponse(result.message, 400);

    auto response = Json.emptyObject
      .set("status", "password_changed");

    return successResponse("Password changed successfully", "", 200, response);
  }

  mixin(HandleTemplate!("handleChangePassword", "changePasswordHandler"));

  protected Json searchHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto filter = req.params.get("filter", "");
    auto users = useCase.searchUsers(tenantId, filter);
    auto list = users.map!(u => u.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("schemas", ["urn:ietf:params:scim:api:messages:2.0:ListResponse"].toJson)
      .set("totalResults", users.length)
      .set("resources", list);

    return successResponse("User search completed successfully", "", 200, responseData);
  }

  mixin(HandleTemplate!("handleSearch", "searchHandler"));
}

private Email[] parseEmails(Json j) {
  Email[] result;
  if (!j.isObject)
    return null;

  if ("emails" !in j)
    return null;

  auto value = j["emails"];
  if (!value.isArray)
    return result;

  return value.toArray.map!(item => Email(item.getString("value"), item.getString(
      "type"), getBoolean(item, "primary"))).array;
}

private PhoneNumber[] parsePhoneNumbers(Json j) {
  PhoneNumber[] result;
  if (!j.isObject)
    return null;

  if ("phoneNumbers" !in j)
    return null;

  auto value = j["phoneNumbers"];
  if (!value.isArray)
    return result;

  return value.toArray.map!(item => PhoneNumber(item.getString("value"), item.getString(
      "type"),
      item.getBoolean("primary"))).array;
}

protected Json scimErrorResponse(string detail, int status) {
  auto errRes = Json.emptyObject
    .set("schemas", Json.emptyArray)
    .set("schemas", Json("urn:ietf:params:scim:api:messages:2.0:Error"))
    .set("detail", Json(detail))
    .set("status", Json(status.to!string));

  return errRes;
}

private void writeScimError(scope HTTPServerResponse res, int status, string detail) {
  auto errRes = scimErrorResponse(detail, status);
  res.writeJsonBody(errRes, status);
}
