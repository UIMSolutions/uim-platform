/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.catalog;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class CatalogController : ManageController {
    private ManageCatalogsUseCase catalogs;

    this(ManageCatalogsUseCase catalogs) {
        this.catalogs = catalogs;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/automation-pilot/catalogs", &handleList);
        router.get("/api/v1/automation-pilot/catalogs/*", &handleGet);
        router.post("/api/v1/automation-pilot/catalogs", &handleCreate);
        router.put("/api/v1/automation-pilot/catalogs/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/catalogs/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);

        auto items = catalogs.listCatalogs(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("message", "Catalogs retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        auto id = CatalogId(data.getString("catalogId", ""));
        if (id.isNull)
            return errorResponse("Missing or invalid catalog ID", 400);

        CatalogDTO dto;
        dto.catalogId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.tags = data.getString("tags");
        dto.version_ = data.getString("version");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = catalogs.createCatalog(dto);
        if (result.hasError)
            return errorResponse(result.errorMessage, 400);

        return successResponse("Catalog created", 201,
            Json.emptyObject.set("id", result.id));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = CatalogId(extractIdFromPath(path));
        if (id.isNull)
            return errorResponse("Invalid catalog ID", 400);

        auto e = catalogs.getCatalog(tenantId, id);
        if (e.isNull)
            return errorResponse("Catalog not found", 404);

        return successResponse("Catalog retrieved successfully", 200,
            e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        auto path = req.requestURI.to!string;
        auto id = CatalogId(extractIdFromPath(path));
        if (id.isNull)
            return errorResponse("Invalid catalog ID", 400);

        CatalogDTO dto;
        dto.tenantId = tenantId;
        dto.catalogId = id;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.tags = data.getString("tags", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = catalogs.updateCatalog(dto);
        if (result.hasError)
            return errorResponse(result.errorMessage, 400);

        return successResponse("Catalog updated", 200,
            Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.getTenantId;
        auto id = CatalogId(precheck.getString("id"));
        if (id.isNull)
            return errorResponse("Invalid catalog ID", 400);

        auto result = catalogs.deleteCatalog(tenantId, id);
        if (result.hasError)
            return errorResponse(result.errorMessage, 400);

        return successResponse("Catalog deleted", 200,
            Json.emptyObject.set("id", result.id));
    }
}
