/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.user;

// import uim.platform.identity.directory.application.usecases.manage.users;
// import uim.platform.identity.directory.application.dto;
// import uim.platform.identity.directory.domain.entities.user;
import uim.platform.identity.directory;

// mixin(ShowModule!());

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
    auto createReq = CreateUserRequest(req.headers.get("X-Tenant-Id", ""),
      data.getString("externalId"), data.getString("userName"), j.parseUserName,
      data.getString("displayName"), data.getString("userType"),
      data.getString("preferredLanguage"), data.getString("locale"),
      data.getString("timezone"), data.getString("password"), parseEmails(j),
      parsePhoneNumbers(j), j.toAddresses, [], // extendedAttributes
      data.getStrings("schemas"),);

    auto result = useCase.createUser(createReq);
    if (result.hasError)
      return scimErrorResponse(result.message, 409);

    auto response = Json.emptyObject;
    response["id"] = Json(result.userId);
    response["schemas"] = Json.emptyArray;
    response["schemas"] ~= Json("urn:ietf:params:scim:schemas:core:2.0:User");
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
    response["Resources"] = serializeUsers(users);

    return successResponse("Users retrieved successfully", "", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto userId = precheck.id;
    auto user = useCase.getUser(userId);
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
    request.userId = userId;
    request.externalId = data.getString("externalId");
    request.userName = data.getString("userName");
    request.displayName = data.getString("displayName");
    request.userType = data.getString("userType");
    request.preferredLanguage = data.getString("preferredLanguage");
    request.locale = data.getString("locale");
    request.timezone = data.getString("timezone");
    request.active = data.getBoolean("active", true);
    request.emails = parseEmails(j);
    request.phoneNumbers = parsePhoneNumbers(j);
    request.addresses = j.toAddresses;
    request.extendedAttributes = []; // extendedAttributes

    auto result = useCase.updateUser(updateReq);
    if (result.hasError)
      writeScimError(res, 404, result.errorMessage);

    auto response = Json.emptyObject;
    response["id"] = Json(userId);
    response["schemas"] = Json.emptyArray;
    response["schemas"] ~= Json("urn:ietf:params:scim:schemas:core:2.0:User");
    return successResponse("User updated successfully", "", 200, response);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = UserId(precheck.id);

    auto result = useCase.deleteUser(tenantId, id);
    if (result.hasError)
      writeScimError(res, 404, result.errorMessage);

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
    if (result.hasError)
      return scimErrorResponse(result.errorMessage, 400);

    auto response = Json.emptyObject
      .set("status", Json("password_changed"));

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
      .set("schemas", Json.emptyArray)
        .set("schemas", "urn:ietf:params:scim:api:messages:2.0:ListResponse")
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
      "type"), getBoolean(item, "primary")))
    .array.toJson;
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
      getBoolean(item, "primary"))).array.toJson;
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
