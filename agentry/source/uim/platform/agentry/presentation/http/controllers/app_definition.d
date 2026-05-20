/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.app_definition;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class AppDefinitionController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listAppDefinitions(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "App definition list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AppDefinitionId(extractIdFromPath(path));
            auto e = usecase.getAppDefinition(tenantId, id);
            if (e.isNull) { writeError(res, 404, "App definition not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            AppDefinitionDTO dto;
            dto.definitionId = AppDefinitionId(j.getString("id"));
            dto.mobileApplicationId = MobileApplicationId(j.getString("mobileApplicationId"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.definitionContent = j.getString("definitionContent");
            dto.definitionFormat = j.getString("definitionFormat");
            dto.schemaVersion = j.getString("schemaVersion");
            dto.authoredBy = j.getString("authoredBy");
            dto.targetPlatform = j.getString("targetPlatform");
            dto.businessObjectModel = j.getString("businessObjectModel");

            auto result = usecase.createAppDefinition(dto);
            if (!result.success) { writeError(res, 400, result.errorMessage); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "App definition created successfully");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            AppDefinitionDTO dto;
            dto.definitionId = AppDefinitionId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.definitionContent = j.getString("definitionContent");
            dto.schemaVersion = j.getString("schemaVersion");

            auto result = usecase.updateAppDefinition(dto);
            if (!result.success) { writeError(res, 404, result.errorMessage); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "App definition updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AppDefinitionId(extractIdFromPath(path));
            auto result = usecase.deleteAppDefinition(tenantId, id);
            if (!result.success) { writeError(res, 404, result.errorMessage); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "App definition deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
