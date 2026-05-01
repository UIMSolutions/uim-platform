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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = catalogs.list();
            auto jarr = items.map!(e => e.catalogToJson()).array;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = CatalogId(extractIdFromPath(path));
            auto e = catalogs.getById(id);
            if (e.id.value.length == 0) { writeError(res, 404, "Catalog not found"); return; }
            res.writeJsonBody(e.catalogToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CatalogDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.tags = j.getString("tags");
            dto.version_ = j.getString("version");
            dto.createdBy = j.getString("createdBy");

            auto result = catalogs.create(dto);
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

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            CatalogDTO dto;
            dto.catalogId = CatalogId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.tags = j.getString("tags");
            dto.updatedBy = j.getString("updatedBy");

            auto result = catalogs.update(dto);
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = CatalogId(extractIdFromPath(path));
            auto result = catalogs.remove(id);
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
