/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.data_entity;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class DataEntityController : ManageController {
    private ManageDataEntitiesUseCase usecase;

    this(ManageDataEntitiesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/build-apps/data-entities", &handleList);
        router.get("/api/v1/build-apps/data-entities/*", &handleGet);
        router.post("/api/v1/build-apps/data-entities", &handleCreate);
        router.put("/api/v1/build-apps/data-entities/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/data-entities/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto items = usecase.listDataEntities(tenantId);
            auto jarr = items.map!(e => e.dataEntityToJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Data entities retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto path = req.requestURI.to!string;
            auto id = DataEntityId(precheck.id);

            auto e = usecase.getDataEntity(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Data entity not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto data = precheck.data;
            DataEntityDTO dto;
            dto.dataEntityId = DataEntityId(precheck.id);
            dto.tenantId = tenantId;
            dto.applicationId = ApplicationId(data.getString("applicationId"));
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.fields = data.getString("fields");
            dto.primaryKey = data.getString("primaryKey");
            dto.indexes = data.getString("indexes");
            dto.validationRules = data.getString("validationRules");
            dto.defaultValues = data.getString("defaultValues");
            dto.relations = data.getString("relations");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createDataEntity(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data entity created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            DataEntityDTO dto;
            dto.dataEntityId = DataEntityId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.fields = data.getString("fields");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateDataEntity(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data entity updated");

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
            auto tenantId = req.getTenantId();

            auto path = req.requestURI.to!string;
            auto id = DataEntityId(precheck.id);
            auto result = usecase.deleteDataEntity(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "Data entity deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
