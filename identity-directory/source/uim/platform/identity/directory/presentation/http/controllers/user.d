/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.user;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.identity.directory.application.usecases.manage.users;
import uim.platform.identity.directory.application.dto;
import uim.platform.identity.directory.domain.entities.user;
import uim.platform.identity_authentication.presentation.http.json_utils;

/// HTTP controller for SCIM 2.0 user management.
class UserController {
  private ManageUsersUseCase useCase;

  this(ManageUsersUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/scim/Users", &handleCreate);
    router.get("/scim/Users", &handleList);
    router.get("/scim/Users/*", &handleGet);
    router.put("/scim/Users/*", &handleUpdate);
    router.delete_("/scim/Users/*", &handleDelete);
    router.post("/scim/Users/change-password", &handleChangePassword);
    router.get("/scim/Users/.search", &handleSearch);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto createReq = CreateUserRequest(req.headers.get("X-Tenant-Id", ""),
          j.getString("externalId"), j.getString("userName"), parseUserName(j),
          j.getString("displayName"), j.getString("userType"),
          j.getString("preferredLanguage"), j.getString("locale"),
          j.getString("timezone"), j.getString("password"), parseEmails(j),
          parsePhoneNumbers(j), parseAddresses(j), [], // extendedAttributes
          jsonStrArray(j, "schemas"),);

      auto result = useCase.createUser(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess())
      {
        response["id"] = Json(result.userId);
        response["schemas"] = Json.emptyArray;
        response["schemas"] ~= Json("urn:ietf:params:scim:schemas:core:2.0:User");
        res.writeJsonBody(response, 201);
      }
      else
      {
        response["schemas"] = Json.emptyArray;
        response["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:Error");
        response["detail"] = Json(result.error);
        response["status"] = Json("409");
        res.writeJsonBody(response, 409);
      }
    }
    catch (Exception e)
    {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto users = useCase.listUsers(tenantId);
      auto response = Json.emptyObject;
      response["schemas"] = Json.emptyArray;
      response["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:ListResponse");
      response["totalResults"] = Json(cast(long) users.length);
      response["startIndex"] = Json(1L);
      response["itemsPerPage"] = Json(cast(long) users.length);
      response["Resources"] = serializeUsers(users);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e)
    {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto userId = extractIdFromPath(req.requestURI);
      auto user = useCase.getUser(userId);
      if (user == User.init)
      {
        writeScimError(res, 404, "User not found");
        return;
      }

      auto response = serializeUser(user);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e)
    {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto userId = extractIdFromPath(req.requestURI);
      auto j = req.json;

      auto updateReq = UpdateUserRequest(userId, parseUserName(j), j.getString("displayName"),
          j.getString("userType"), j.getString("preferredLanguage"),
          j.getString("locale"), j.getString("timezone"),
          j.getBoolean("active", true), parseEmails(j), parsePhoneNumbers(j),
          parseAddresses(j), [], // extendedAttributes
          );

      auto error = useCase.updateUser(updateReq);
      if (error.length > 0)
      {
        writeScimError(res, 404, error);
      }
      else
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
    }
    catch (Exception e)
    {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto userId = extractIdFromPath(req.requestURI);
      auto error = useCase.deleteUser(userId);
      if (error.length > 0)
      {
        writeScimError(res, 404, error);
      }
      else
      {
        res.writeBody("", 204);
      }
    }
    catch (Exception e)
    {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleChangePassword(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto error = useCase.changePassword(j.getString("userId"),
          j.getString("currentPassword"), j.getString("newPassword"));
      if (error.length > 0)
      {
        writeScimError(res, 400, error);
      }
      else
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("password_changed");
        res.writeJsonBody(resp, 200);
      }
    }
    catch (Exception e)
    {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto filter = req.params.get("filter", "");
      auto users = useCase.searchUsers(tenantId, filter);
      auto response = Json.emptyObject;
      response["schemas"] = Json.emptyArray;
      response["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:ListResponse");
      response["totalResults"] = Json(cast(long) users.length);
      response["Resources"] = serializeUsers(users);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e)
    {
      writeScimError(res, 500, "Internal server error");
    }
  }
}

private Json serializeUser(User user) {
  auto j = Json.emptyObject;
  j["id"] = Json(user.id);
  j["externalId"] = Json(user.externalId);
  j["userName"] = Json(user.userName);
  j["displayName"] = Json(user.getDisplayName());
  j["userType"] = Json(user.userType);
  j["active"] = Json(user.active);
  j["preferredLanguage"] = Json(user.preferredLanguage);
  j["locale"] = Json(user.locale);
  j["timezone"] = Json(user.timezone);

  // Name
  auto nameJson = Json.emptyObject;
  nameJson["formatted"] = Json(user.name.formatted);
  nameJson["familyName"] = Json(user.name.familyName);
  nameJson["givenName"] = Json(user.name.givenName);
  nameJson["middleName"] = Json(user.name.middleName);
  nameJson["honorificPrefix"] = Json(user.name.honorificPrefix);
  nameJson["honorificSuffix"] = Json(user.name.honorificSuffix);
  j["name"] = nameJson;

  // Emails
  j["emails"] = toJsonArray(user.emails);

  // Phone numbers
  j["phoneNumbers"] = toJsonArray(user.phoneNumbers);

  // Groups
  auto groups = Json.emptyArray;
  foreach (gid; user.groupIds)
  {
    auto g = Json.emptyObject;
    g["value"] = Json(gid);
    groups ~= g;
  }
  j["groups"] = groups;

  // Schemas
  auto schemas = Json.emptyArray;
  schemas ~= Json("urn:ietf:params:scim:schemas:core:2.0:User");
  foreach (s; user.schemas)
    schemas ~= Json(s);
  j["schemas"] = schemas;

  // Meta
  auto meta = Json.emptyObject;
  meta["resourceType"] = Json("User");
  meta["created"] = Json(cast(long) user.createdAt);
  meta["lastModified"] = Json(cast(long) user.updatedAt);
  j["meta"] = meta;

  return j;
}

private Json serializeUsers(User[] users) {
  auto arr = Json.emptyArray;
  foreach (u; users)
    arr ~= serializeUser(u);
  return arr;
}

private UserName parseUserName(Json j) {
  if (!j.isObject)
    return UserName.init;

  auto nameVal = "name" in j;
  if (nameVal is null || (*nameVal).type != Json.Type.object)
    return UserName.init;

  auto n = *nameVal;
  return UserName(n.getString("formatted"), n.getString("familyName"),
      n.getString("givenName"), n.getString("middleName"),
      n.getString("honorificPrefix"), n.getString("honorificSuffix"),);
}

private Email[] parseEmails(Json j) {
  Email[] result;
  if (!j.isObject)
    return result;
  auto val = "emails" in j;
  if (val is null || (*val).type != Json.Type.array)
    return result;
  foreach (item; *val)
  {
    result ~= Email(item.getString("value"), item.getString("type"), jsonBool(item, "primary"),);
  }
  return result;
}

private PhoneNumber[] parsePhoneNumbers(Json j) {
  PhoneNumber[] result;
  if (!j.isObject)
    return result;
  auto val = "phoneNumbers" in j;
  if (val is null || (*val).type != Json.Type.array)
    return result;
  foreach (item; *val)
  {
    result ~= PhoneNumber(item.getString("value"), item.getString("type"),
        jsonBool(item, "primary"),);
  }
  return result;
}

private Address[] parseAddresses(Json j) {
  Address[] result;
  if (!j.isObject)
    return result;
  auto val = "addresses" in j;
  if (val is null || (*val).type != Json.Type.array)
    return result;
  foreach (item; *val)
  {
    result ~= Address(item.getString("formatted"), item.getString("streetAddress"),
        item.getString("locality"), item.getString("region"),
        item.getString("postalCode"), item.getString("country"),
        item.getString("type"), jsonBool(item, "primary"),);
  }
  return result;
}

private void writeScimError(scope HTTPServerResponse res, int status, string detail) {
  auto errRes = Json.emptyObject;
  errRes["schemas"] = Json.emptyArray;
  errRes["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:Error");
  errRes["detail"] = Json(detail);

  // import std.conv : to;
  errRes["status"] = Json(status.to!string);
  res.writeJsonBody(errRes, status);
}
