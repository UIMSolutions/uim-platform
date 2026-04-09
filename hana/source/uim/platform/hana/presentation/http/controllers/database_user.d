/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.database_user;

// import uim.platform.hana.application.usecases.manage.database_users;
// import uim.platform.hana.application.dto;
// import uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class DatabaseUserController : PlatformController {
  private ManageDatabaseUsersUseCase uc;

  this(ManageDatabaseUsersUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/users", &handleList);
    router.get("/api/v1/hana/users/*", &handleGet);
    router.post("/api/v1/hana/users", &handleCreate);
    router.put("/api/v1/hana/users/*", &handleUpdate);
    router.delete_("/api/v1/hana/users/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDatabaseUserRequest r;
      r.tenantId = req.getTenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.userName = j.getString("userName");
      r.password = j.getString("password");
      r.authType = j.getString("authType");
      r.defaultSchema = j.getString("defaultSchema");
      r.isRestricted = jsonBool(j, "isRestricted");
      r.forcePasswordChange = jsonBool(j, "forcePasswordChange", true);
      r.roles = jsonStrArray(j, "roles");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Database user created");
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
      TenantId tenantId = req.getTenantId;
      auto users = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref u; users) {
        auto uj = Json.emptyObject;
        uj["id"] = Json(u.id);
        uj["userName"] = Json(u.userName);
        uj["status"] = Json(u.status.to!string);
        uj["defaultSchema"] = Json(u.defaultSchema);
        uj["isRestricted"] = Json(u.isRestricted);
        uj["createdAt"] = Json(u.createdAt);
        jarr ~= uj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) users.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto u = uc.get_(id);
      if (u.id.isEmpty) {
        writeError(res, 404, "Database user not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(u.id);
      resp["userName"] = Json(u.userName);
      resp["status"] = Json(u.status.to!string);
      resp["defaultSchema"] = Json(u.defaultSchema);
      resp["isRestricted"] = Json(u.isRestricted);
      resp["forcePasswordChange"] = Json(u.forcePasswordChange);
      resp["failedLoginAttempts"] = Json(cast(long) u.failedLoginAttempts);
      resp["lastLoginAt"] = Json(u.lastLoginAt);
      resp["createdAt"] = Json(u.createdAt);
      resp["modifiedAt"] = Json(u.modifiedAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateDatabaseUserRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.password = j.getString("password");
      r.defaultSchema = j.getString("defaultSchema");
      r.isRestricted = jsonBool(j, "isRestricted");
      r.forcePasswordChange = jsonBool(j, "forcePasswordChange");
      r.roles = jsonStrArray(j, "roles");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Database user updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
