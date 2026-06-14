/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.database_user;
// import uim.platform.hana.application.usecases.manage.database_users;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

// mixin(ShowModule!());

@safe:

class DatabaseUserController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDatabaseUserRequest r;
    r.tenantId = tenantId;
    r.instanceId = data.getString("instanceId");
    r.id = precheck.id;
    r.userName = data.getString("userName");
    r.password = data.getString("password");
    r.authType = data.getString("authType");
    r.defaultSchema = data.getString("defaultSchema");
    r.isRestricted = data.getBoolean("isRestricted");
    r.forcePasswordChange = data.getBoolean("forcePasswordChange", true);
    r.roles = data.getStrings("roles");

    auto result = usecase.createDatabaseUser(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Database user created");

    return successResponse("Database user created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

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
      .set("resources", list);

    return successResponse("Database users retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatabaseUserId(precheck.id);

    auto u = usecase.getDatabaseUser(tenantId, id);
    if (u.isNull)
      return errorResponse("Database user not found", 404);

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

    return successResponse("Database user retrieved successfully", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateDatabaseUserRequest r;
    r.tenantId = tenantId;
    r.id = DatabaseUserId(precheck.id);
    r.password = data.getString("password");
    r.defaultSchema = data.getString("defaultSchema");
    r.isRestricted = data.getBoolean("isRestricted");
    r.forcePasswordChange = data.getBoolean("forcePasswordChange");
    r.roles = data.getStrings("roles");

    auto result = usecase.updateDatabaseUser(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Database user updated successfully", 200, resp);

  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DatabaseUserId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid database user ID", 400);

    auto result = usecase.deleteDatabaseUser(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Database user deleted successfully", 200, resp);
  }
}
