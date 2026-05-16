/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.catalog;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class CatalogController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto items = catalogs.listCatalogs(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Catalogs retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = CatalogId(extractIdFromPath(path));

            auto e = catalogs.getCatalog(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Catalog not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;

            CatalogDTO dto;
            dto.catalogId = CatalogId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.tags = j.getString("tags");
            dto.version_ = j.getString("version");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = catalogs.createCatalog(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Catalog created");
                
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;
            CatalogDTO dto;
            dto.tenantId = tenantId;
            dto.catalogId = CatalogId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.tags = j.getString("tags");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = catalogs.updateCatalog(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Catalog updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = CatalogId(extractIdFromPath(path));

            auto result = catalogs.deleteCatalog(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Catalog deleted");
                    
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
