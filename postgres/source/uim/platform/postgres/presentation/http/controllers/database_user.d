/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.http.controllers.database_user;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class DatabaseUserController : ManageController {
    private ManageDatabaseUsersUseCase users;

    this(ManageDatabaseUsersUseCase users) { this.users = users; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/postgres/db-users",        &handleList);
        router.get("/api/v1/postgres/db-users/*",      &handleGet);
        router.post("/api/v1/postgres/db-users",       &handleCreate);
        router.put("/api/v1/postgres/db-users/*",      &handleUpdate);
        router.delete_("/api/v1/postgres/db-users/*",  &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto items = users.listDatabaseUsers(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Database users retrieved successfully")
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = DatabaseUserId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = users.getDatabaseUser(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Database user not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        DatabaseUserDTO dto;
        dto.databaseUserId = DatabaseUserId(data.getString("databaseUserId", ""));
        dto.tenantId       = tenantId;
        dto.instanceId     = ServiceInstanceId(data.getString("instanceId", ""));
        dto.username       = data.getString("username", "");
        dto.roles          = data.getString("roles", "readonly");
        dto.createdBy      = UserId(data.getString("createdBy", ""));
        auto result = users.createDatabaseUser(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Database user created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        DatabaseUserDTO dto;
        dto.databaseUserId = DatabaseUserId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId       = tenantId;
        dto.roles          = data.getString("roles", "");
        dto.updatedBy      = UserId(data.getString("updatedBy", ""));
        auto result = users.updateDatabaseUser(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Database user updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = DatabaseUserId(extractIdFromPath(req.requestURI.to!string));
        auto result = users.deleteDatabaseUser(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Database user deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
