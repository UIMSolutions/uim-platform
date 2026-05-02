/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.business_user;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.abap_environment.application.usecases.manage.business_users;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.business_user;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
class BusinessUserController : PlatformController {
  private ManageBusinessUsersUseCase uc;

  this(ManageBusinessUsersUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-users", &handleCreate);
    router.get("/api/v1/business-users", &handleList);
    router.get("/api/v1/business-users/*", &handleGetById);
    router.put("/api/v1/business-users/*", &handleUpdate);
    router.delete_("/api/v1/business-users/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateBusinessUserRequest r;
      r.tenantId = req.getTenantId;
      r.systemInstanceId = j.getString("systemInstanceId");
      r.username = j.getString("username");
      r.firstName = j.getString("firstName");
      r.lastName = j.getString("lastName");
      r.email = j.getString("email");
      r.roleIds = getStringArray(j, "roleIds");

      auto result = uc.createUser(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
        .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
      auto users = uc.listUsers(systemId);
      auto arr = users.map!(user => user.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", users.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = BusinessUserId(extractIdFromPath(req.requestURI));
      auto user = uc.getUser(id);
      if (user.isNull) {
        writeError(res, 404, "Business user not found");
        return;
      }
      res.writeJsonBody(user.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = BusinessUserId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      UpdateBusinessUserRequest r;
      r.firstName = j.getString("firstName");
      r.lastName = j.getString("lastName");
      r.email = j.getString("email");
      r.status = j.getString("status");
      r.roleIds = getStringArray(j, "roleIds");

      auto result = uc.updateUser(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "Business user updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = BusinessUserId(extractIdFromPath(req.requestURI));
      auto result = uc.deleteUser(id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Business user deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeUser(const BusinessUser u) {
    auto j = Json.emptyObject
      .set("id", u.id)
      .set("tenantId", u.tenantId)
      .set("systemInstanceId", u.systemInstanceId)
      .set("username", u.username)
      .set("firstName", u.firstName)
      .set("lastName", u.lastName)
      .set("email", u.email)
      .set("status", u.status.to!string)
      .set("passwordChangeRequired", u.passwordChangeRequired)
      .set("lastLoginAt", u.lastLoginAt)
      .set("createdAt", u.createdAt)
      .set("updatedAt", u.updatedAt);

    if (u.roleAssignments.length > 0) {
      auto roles = Json.emptyArray;
      foreach (ra; u.roleAssignments) {
        roles ~= Json.emptyObject
        .set("roleId", ra.roleId)
        .set("roleName", ra.roleName)
        .set("assignedAt", ra.assignedAt);
      }
      j["roleAssignments"] = roles;
    }

    return j;
  }
}
