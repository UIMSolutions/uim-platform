/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.entity_type;
// import uim.platform.situation_automation.application.usecases.manage.entity_types;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:

class EntityTypeController : ManageHttpController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;

        CreateEntityTypeRequest r;
        r.tenantId = tenantId;
        r.entityTypeId = EntityTypeId(data.getString("entityTypeId"));
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.category = data.getString("category");
        r.sourceSystem = data.getString("sourceSystem");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createEntityType(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Entity type created");

        return successResponse("Entity type created successfully", 201, resp);
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

        return successResponse("Entity types retrieved successfully", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EntityTypeId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid entity type ID", 400);

        auto et = usecase.getEntityType(tenantId, id);
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

        return successResponse("Entity type retrieved successfully", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        UpdateEntityTypeRequest r;
        r.tenantId = tenantId;
        r.entityTypeId = EntityTypeId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.category = data.getString("category");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateEntityType(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id);
        return successResponse("Entity type updated successfully", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EntityTypeId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid entity type ID", 400);

        auto result = usecase.deleteEntityType(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Entity type deleted");

        return successResponse("Entity type deleted successfully", 200, resp);
    }
}
