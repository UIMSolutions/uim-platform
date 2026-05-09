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

class EntityTypeController : PlatformController {
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateEntityTypeRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.sourceSystem = j.getString("sourceSystem");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Entity type created");

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
            auto tenantId = req.getTenantId;
            auto types = usecase.list(tenantId);

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

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto et = usecase.getById(tenantId, id);
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

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto j = req.json;
            UpdateEntityTypeRequest r;
            r.tenantId = tenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Entity type updated");

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
            

            auto id = EntityTypeId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteEntityType(id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Entity type deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
