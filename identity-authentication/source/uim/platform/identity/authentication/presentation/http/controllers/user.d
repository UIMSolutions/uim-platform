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

mixin(ShowModule!());
@safe:
/// HTTP controller for SCIM-like user management API.
class UserController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateUserRequest request;
      request.tenantId = tenantId;
      request.userName = j.getString("userName");
      request.email = j.getString("email");
      request.firstName = j.getString("firstName");
      request.lastName = j.getString("lastName");
      request.password = j.getString("password");
      request.phoneNumber = j.getString("phoneNumber");

      auto result = useCase.createUser(request);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["userId"] = Json(result.userId);
        res.writeJsonBody(response, 201);
      } else {
        response["error"] = Json(result.message);
        res.writeJsonBody(response, 409);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.params.get("tenantId", "");
      if (tenantId.isEmpty)
        tenantId = req.getTenantId;

      auto users = useCase.listUsers(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = users.length.toJson;
      response["resources"] = users.toJson;
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
auto tenantId = req.getTenantId;
      auto path = req.requestURI;
      auto userId = extractIdFromPath(path);

      auto user = useCase.getUser(tenantId, userId);
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
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto path = req.requestURI;
      auto userId = extractIdFromPath(path);
      auto j = req.json;

      auto updateReq = UpdateUserRequest(tenantId, userId, j.getString("firstName"),
        j.getString("lastName"), j.getString("phoneNumber"));

      auto error = useCase.updateUser(updateReq);
      if (error.length > 0) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json(error);
        res.writeJsonBody(errRes, 404);
      } else {
        auto resp = Json.emptyObject
          .set("status", "updated");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleChangePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto error = useCase.changePassword(tenantId, j.getString("userId"),
        j.getString("oldPassword"), j.getString("newPassword"));

      if (error.length > 0) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json(error);
        res.writeJsonBody(errRes, 400);
      } else {
        auto resp = Json.emptyObject
          .set("status", "password_changed");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject
        .set("error", "Internal server error");

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
