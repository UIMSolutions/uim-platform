/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.database_user;
// import uim.platform.hana.application.usecases.manage.database_users;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class DatabaseUserController : ManageController {
  private ManageDatabaseUsersUseCase usecase;

  this(ManageDatabaseUsersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/hana/users", &handleList);
    router.get("/api/v1/hana/users/*", &handleGet);
    router.post("/api/v1/hana/users", &handleCreate);
    router.put("/api/v1/hana/users/*", &handleUpdate);
    router.delete_("/api/v1/hana/users/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      CreateDatabaseUserRequest r;
      r.tenantId = tenantId;
      r.instanceId = data.getString("instanceId");
      r.id = precheck.id;
      r.userName = data.getString("userName");
      r.password = data.getString("password");
      r.authType = data.getString("authType");
      r.defaultSchema = data.getString("defaultSchema");
      r.isRestricted = j.getBoolean("isRestricted");
      r.forcePasswordChange = j.getBoolean("forcePasswordChange", true);
      r.roles = getStrings(j, "roles");

      auto result = usecase.createDatabaseUser(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Database user created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto users = usecase.listDatabaseUsers(tenantId);

      auto jarr = Json.emptyArray;
      foreach (u; users) {
        jarr ~= Json.emptyObject
          .set("id", u.id)
          .set("userName", u.userName)
          .set("status", u.status.to!string)
          .set("defaultSchema", u.defaultSchema)
          .set("isRestricted", u.isRestricted)
          .set("createdAt", u.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", users.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DatabaseUserprecheck.id);

      auto u = usecase.getDatabaseUser(tenantId, id);
      if (u.isNull) {
        writeError(res, 404, "Database user not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", u.id)
        .set("userName", u.userName)
        .set("status", u.status.to!string)
        .set("defaultSchema", u.defaultSchema)
        .set("isRestricted", u.isRestricted)
        .set("forcePasswordChange", u.forcePasswordChange)
        .set("failedLoginAttempts", u.failedLoginAttempts)
        .set("lastLoginAt", u.lastLoginAt)
        .set("createdAt", u.createdAt)
        .set("updatedAt", u.updatedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {

      auto j = req.json;
      UpdateDatabaseUserRequest r;
      r.tenantId = tenantId;
      r.id = DatabaseUserprecheck.id);
      r.password = data.getString("password");
      r.defaultSchema = data.getString("defaultSchema");
      r.isRestricted = j.getBoolean("isRestricted");
      r.forcePasswordChange = j.getBoolean("forcePasswordChange");
      r.roles = getStrings(j, "roles");

      auto result = usecase.updateDatabaseUser(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Database user updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DatabaseUserprecheck.id);

      auto result = usecase.deleteDatabaseUser(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
