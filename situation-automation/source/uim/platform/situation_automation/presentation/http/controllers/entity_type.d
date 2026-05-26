/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.entity_type;
// import uim.platform.situation_automation.application.usecases.manage.entity_types;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class EntityTypeController : ManageController {
    private ManageEntityTypesUseCase usecase;

    this(ManageEntityTypesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/situation-automation/entity-types", &handleList);
        router.get("/api/v1/situation-automation/entity-types/*", &handleGet);
        router.post("/api/v1/situation-automation/entity-types", &handleCreate);
        router.put("/api/v1/situation-automation/entity-types/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/entity-types/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            
            CreateEntityTypeRequest r;
            r.tenantId = tenantId;
            r.entityTypeId = EntityTypeId(j.getString("entityTypeId"));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.sourceSystem = j.getString("sourceSystem");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createEntityType(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Entity type created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto types = usecase.listEntityTypes(tenantId);

            auto jarr = Json.emptyArray;
            foreach (et; types) {
                jarr ~= Json.emptyObject
                .set("id", et.id)
                .set("name", et.name)
                .set("description", et.description)
                .set("category", et.category.to!string)
                .set("sourceSystem", et.sourceSystem)
                .set("createdAt", et.createdAt);
            }

            auto resp = Json.emptyObject
                .set("count", Json(types.length))
                .set("resources", jarr)
                .set("message", "Entity types retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto entityTypeId = EntityTypeprecheck.id);

            auto et = usecase.getEntityType(tenantId, entityTypeId);
            if (et.isNull) {
                writeError(res, 404, "Entity type not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", et.id)
                .set("name", et.name)
                .set("description", et.description)
                .set("category", et.category.to!string)
                .set("sourceSystem", et.sourceSystem)
                .set("createdBy", et.createdBy)
                .set("updatedBy", et.updatedBy)
                .set("createdAt", et.createdAt)
                .set("updatedAt", et.updatedAt)
                .set("relatedTemplateIds", stringsToJsonArray(et.relatedTemplateIds));

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            
            UpdateEntityTypeRequest r;
            r.tenantId = tenantId;
            r.entityTypeId = EntityTypeprecheck.id);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateEntityType(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Entity type updated");

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
            auto tenantId = req.getTenantId;
            auto id = EntityTypeprecheck.id);

            auto result = usecase.deleteEntityType(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Entity type deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
