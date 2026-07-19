/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.http.controllers.database_extension;

import uim.platform.postgres;
mixin(ShowModule!());

@safe:

class DatabaseExtensionController : ManageHttpController {
    private ManageDatabaseExtensionsUseCase extensions;

    this(ManageDatabaseExtensionsUseCase extensions) { this.extensions = extensions; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/postgres/extensions",        &handleList);
        router.get("/api/v1/postgres/extensions/*",      &handleGet);
        router.post("/api/v1/postgres/extensions",       &handleCreate);
        router.delete_("/api/v1/postgres/extensions/*",  &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto items = extensions.listDatabaseExtensions(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Database extensions retrieved successfully")
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto id = DatabaseExtensionId(precheck.id);
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = extensions.getDatabaseExtension(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Extension not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        DatabaseExtensionDTO dto;
        dto.databaseExtensionId = DatabaseExtensionId(data.getString("databaseExtensionId", ""));
        dto.tenantId            = tenantId;
        dto.instanceId          = ServiceInstanceId(data.getString("instanceId", ""));
        dto.extensionName       = data.getString("extensionName", "");
        dto.extensionVersion    = data.getString("extensionVersion", "");
        dto.schema_             = data.getString("schema", "");
        dto.createdBy           = UserId(data.getString("createdBy", ""));
        auto result = extensions.createDatabaseExtension(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Extension enabled successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto id = DatabaseExtensionId(precheck.id);
        auto result = extensions.deleteDatabaseExtension(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Extension disabled successfully").set("status", "success").set("statusCode", 200);
    }
}
