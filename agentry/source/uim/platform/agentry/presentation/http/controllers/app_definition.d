/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.app_definition;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

class AppDefinitionController : ManageHttpController {
    private ManageAppDefinitionsUseCase usecase;

    this(ManageAppDefinitionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/agentry/app-definitions", &handleList);
        router.get("/api/v1/agentry/app-definitions/*", &handleGet);
        router.post("/api/v1/agentry/app-definitions", &handleCreate);
        router.put("/api/v1/agentry/app-definitions/*", &handleUpdate);
        router.delete_("/api/v1/agentry/app-definitions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listAppDefinitions(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("App definition list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        AppDefinitionDTO dto;
        dto.definitionId = AppDefinitionId(precheck.id);
        dto.applicationId = MobileApplicationId(data.getString("mobileApplicationId"));
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.definitionContent = data.getString("definitionContent");
        dto.definitionFormat = data.getString("definitionFormat");
        dto.schemaVersion = data.getString("schemaVersion");
        dto.authoredBy = data.getString("authoredBy");
        dto.targetPlatform = data.getString("targetPlatform");
        dto.businessObjectModel = data.getString("businessObjectModel");

        auto result = usecase.createAppDefinition(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("App definition created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = AppDefinitionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid app definition ID", 400);

        auto definition = usecase.getAppDefinition(tenantId, id);
        if (definition.isNull)
            return errorResponse("App definition not found", 404);

        auto responseData = definition.toJson();
        return successResponse("App definition retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto data = precheck.data;
        auto id = AppDefinitionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid app definition ID", 400);

        AppDefinitionDTO dto;
        dto.definitionId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.definitionContent = data.getString("definitionContent");
        dto.schemaVersion = data.getString("schemaVersion");

        auto result = usecase.updateAppDefinition(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("App definition updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = AppDefinitionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid app definition ID", 400);

        auto result = usecase.deleteAppDefinition(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject
            .set("id", id);

        return successResponse("App definition deleted successfully", "Deleted", 200, responseData);
    }
}
