/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.controllers.user;
// 
// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.identity_authentication.application.usecases.manage.users;
// import uim.platform.identity_authentication.application.dto;
// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.presentation.http.json_utils;
// 
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// HTTP controller for SCIM-like user management API.
class UserController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateUserRequest(j.getString("tenantId"), j.getString("userName"),
          j.getString("email"), j.getString("firstName"), j.getString("lastName"),
          j.getString("password"), j.getString("phoneNumber"));

      auto result = useCase.createUser(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["userId"] = Json(result.userId);
        res.writeJsonBody(response, 201);
      }
      else
      {
        response["error"] = Json(result.error);
        res.writeJsonBody(response, 409);
      }
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.params.get("tenantId", "");
      if (tenantId.isEmpty)
        tenantId = req.getTenantId;

      auto users = useCase.listUsers(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = users.length.toJson;
      response["resources"] = users.toJson;
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.conv : to;

      auto path = req.requestURI;
      auto userId = extractIdFromPath(path);

      auto user = useCase.getUser(userId);
      if (user == User.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("User not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      auto response = toJsonValue(user);
      // Remove sensitive field
      response.remove("passwordHash");
      response.remove("mfaSecret");
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto path = req.requestURI;
      auto userId = extractIdFromPath(path);
      auto j = req.json;

      auto updateReq = UpdateUserRequest(userId, j.getString("firstName"),
          j.getString("lastName"), j.getString("phoneNumber"));

      auto error = useCase.updateUser(updateReq);
      if (error.length > 0) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json(error);
        res.writeJsonBody(errRes, 404);
      }
      else
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleChangePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto error = useCase.changePassword(j.getString("userId"),
          j.getString("oldPassword"), j.getString("newPassword"));

      if (error.length > 0) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json(error);
        res.writeJsonBody(errRes, 400);
      }
      else
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("password_changed");
        res.writeJsonBody(resp, 200);
      }
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }
}

private string extractIdFromPath(string path) {
  // import std.string : lastIndexOf;

  auto idx = path.lastIndexOf('/');
  if (idx >= 0 && idx + 1 < path.length)
    return path[idx + 1 .. $];
  return "";
}
