/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.user;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.identity.directory.application.usecases.manage.users;
// import uim.platform.identity.directory.application.dto;
// import uim.platform.identity.directory.domain.entities.user;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for SCIM 2.0 user management.
class UserController : PlatformController {
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
    router.get("/scim/Users/.search", &handleSearch);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateUserRequest(req.headers.get("X-Tenant-Id", ""),
        j.getString("externalId"), j.getString("userName"), j.parseUserName,
        j.getString("displayName"), j.getString("userType"),
        j.getString("preferredLanguage"), j.getString("locale"),
        j.getString("timezone"), j.getString("password"), parseEmails(j),
        parsePhoneNumbers(j), j.toAddresses, [], // extendedAttributes
        getStringArray(j, "schemas"),);

      auto result = useCase.createUser(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["id"] = Json(result.userId);
        response["schemas"] = Json.emptyArray;
        response["schemas"] ~= Json("urn:ietf:params:scim:schemas:core:2.0:User");
        res.writeJsonBody(response, 201);
      } else {
        response["schemas"] = Json.emptyArray;
        response["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:Error");
        response["detail"] = Json(result.error);
        response["status"] = Json("409");
        res.writeJsonBody(response, 409);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto users = useCase.listUsers(tenantId);
      auto response = Json.emptyObject;
      response["schemas"] = Json.emptyArray;
      response["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:ListResponse");
      response["totalResults"] = Json(users.length);
      response["startIndex"] = Json(1L);
      response["itemsPerPage"] = Json(users.length);
      response["Resources"] = serializeUsers(users);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto userId = extractIdFromPath(req.requestURI);
      auto user = useCase.getUser(userId);
      if (user == User.init) {
        writeScimError(res, 404, "User not found");
        return;
      }

      auto response = serializeUser(user);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto userId = extractIdFromPath(req.requestURI);
      auto j = req.json;

      auto updateReq = UpdateUserRequest(userId, j.parseUserName, j.getString("displayName"),
        j.getString("userType"), j.getString("preferredLanguage"),
        j.getString("locale"), j.getString("timezone"),
        j.getBoolean("active", true), parseEmails(j), parsePhoneNumbers(j),
        j.toAddresses, [], // extendedAttributes

        

      );

      auto error = useCase.updateUser(updateReq);
      if (error.length > 0) {
        writeScimError(res, 404, error);
      } else {
        auto resp = Json.emptyObject
        .set("status", "updated");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto userId = extractIdFromPath(req.requestURI);
      auto error = useCase.deleteUser(userId);
      if (error.length > 0) {
        writeScimError(res, 404, error);
      } else {
        res.writeBody("", 204);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleChangePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto error = useCase.changePassword(j.getString("userId"),
        j.getString("currentPassword"), j.getString("newPassword"));
      if (error.length > 0) {
        writeScimError(res, 400, error);
      } else {
        auto resp = Json.emptyObject
          .set("status", Json("password_changed"));

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto filter = req.params.get("filter", "");
      auto users = useCase.searchUsers(tenantId, filter);
      auto response = Json.emptyObject
        .set("schemas", Json.emptyArray)
        .set("schemas", "urn:ietf:params:scim:api:messages:2.0:ListResponse")
        .set("totalResults", users.length)
        .set("Resources", serializeUsers(users));

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }
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

  return value.toArray.map!(item => Email(item.getString("value"), item.getString("type"), getBoolean(item, "primary")))
    .array;
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

  return value.toArray.map!(item => PhoneNumber(item.getString("value"), item.getString("type"),
      getBoolean(item, "primary"))).array;
}


private void writeScimError(scope HTTPServerResponse res, int status, string detail) {
  auto errRes = Json.emptyObject
    .set("schemas", Json.emptyArray)
    .set("schemas", Json("urn:ietf:params:scim:api:messages:2.0:Error"))
    .set("detail", Json(detail))
    .set("status", Json(status.to!string));

  res.writeJsonBody(errRes, status);
}
