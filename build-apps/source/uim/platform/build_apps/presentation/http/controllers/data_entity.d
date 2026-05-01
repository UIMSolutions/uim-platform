/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.data_entity;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class DataEntityController : PlatformController {
    private ManageDataEntitiesUseCase uc;

    this(ManageDataEntitiesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/build-apps/data-entities", &handleList);
        router.get("/api/v1/build-apps/data-entities/*", &handleGet);
        router.post("/api/v1/build-apps/data-entities", &handleCreate);
        router.put("/api/v1/build-apps/data-entities/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/data-entities/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items)
                jarr ~= e.dataEntityToJson();
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Data entities retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(DataEntityId(id));
            if (e.id.value.length == 0) {
                writeError(res, 404, "Data entity not found");
                return;
            }
            res.writeJsonBody(e.dataEntityToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            DataEntityDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.applicationId = j.getString("applicationId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.fields = j.getString("fields");
            dto.primaryKey = j.getString("primaryKey");
            dto.indexes = j.getString("indexes");
            dto.validationRules = j.getString("validationRules");
            dto.defaultValues = j.getString("defaultValues");
            dto.relations = j.getString("relations");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data entity created");

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
            DataEntityDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.fields = j.getString("fields");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data entity updated");

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
            auto id = extractIdFromPath(path);
            auto result = uc.remove(DataEntityId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Data entity deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
