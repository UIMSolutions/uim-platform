/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_action;
// 
// import uim.platform.situation_automation.application.usecases.manage.situation_actions;
// import uim.platform.situation_automation.application.dto;
// 
import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:

class SituationActionController : ManageHttpController {
    private ManageSituationActionsUseCase usecase;

    this(ManageSituationActionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/situation-automation/actions", &handleList);
        router.get("/api/v1/situation-automation/actions/*", &handleGet);
        router.post("/api/v1/situation-automation/actions", &handleCreate);
        router.put("/api/v1/situation-automation/actions/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/actions/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateSituationActionRequest r;
            r.tenantId = tenantId;
            r.situationActionId = SituationActionId(precheck.id);
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.type = data.getString("type");
            r.baseUrl = data.getString("baseUrl");
            r.path = data.getString("path");
            r.method = data.getString("method");
            r.authType = data.getString("authType");
            r.destinationName = data.getString("destinationName");
            r.webhookUrl = data.getString("webhookUrl");
            r.emailTemplate = data.getString("emailTemplate");
            r.scriptContent = data.getString("scriptContent");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createSituationAction(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id);
           return successResponse("Situation action created successfully", 201, resp); 
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto actions = usecase.listSituationActions(tenantId);

            auto jarr = Json.emptyArray;
            foreach (a; actions) {
                jarr ~= Json.emptyObject
                .set("id", a.id)
                .set("name", a.name)
                .set("description", a.description)
                .set("type", a.type.to!string)
                .set("status", a.status.to!string)
                .set("lastExecutedAt", a.lastExecutedAt)
                .set("executionCount", a.executionCount)
                .set("createdAt", a.createdAt);
            }

            auto resp = Json.emptyObject
                .set("count", actions.length)
                .set("resources", list);
                
            return successResponse("Situation actions retrieved successfully", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = SituationActionId(precheck.id);

            auto a = usecase.getSituationAction(tenantId, id);
            if (a.isNull) {
                writeError(res, 404, "Situation action not found");
                return;
            }

            auto apiCfg = Json.emptyObject
                .set("baseUrl", a.apiConfig.baseUrl)
                .set("path", a.apiConfig.path)
                .set("authType", a.apiConfig.authType)
                .set("destinationName", a.apiConfig.destinationName);

            auto resp = Json.emptyObject
                .set("id", a.id.value)
                .set("name", a.name)
                .set("description", a.description)
                .set("type", a.type.to!string)
                .set("status", a.status.to!string)
                .set("webhookUrl", a.webhookUrl)
                .set("emailTemplate", a.emailTemplate)
                .set("createdBy", a.createdBy)
                .set("updatedBy", a.updatedBy)
                .set("createdAt", a.createdAt)
                .set("updatedAt", a.updatedAt)
                .set("lastExecutedAt", a.lastExecutedAt)
                .set("executionCount", a.executionCount)
                .set("apiConfig", apiCfg);

            return successResponse("Situation action retrieved successfully", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            UpdateSituationActionRequest r;
            r.tenantId = tenantId;
            r.situationActionId = SituationActionId(precheck.id);
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.baseUrl = data.getString("baseUrl");
            r.path = data.getString("path");
            r.authType = data.getString("authType");
            r.destinationName = data.getString("destinationName");
            r.webhookUrl = data.getString("webhookUrl");
            r.emailTemplate = data.getString("emailTemplate");
            r.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateSituationAction(r);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Situation action updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = SituationActionId(precheck.id);

            auto result = usecase.deleteSituationAction(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Situation action deleted successfully", 200, responseData);
    }
}
