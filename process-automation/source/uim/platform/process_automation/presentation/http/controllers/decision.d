/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.decision;
// import uim.platform.process_automation.application.usecases.manage.decisions;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class DecisionController : ManageHttpController {
    private ManageDecisionsUseCase decisionUsecase;

    this(ManageDecisionsUseCase decisionUsecase) {
        this.decisionUsecase = decisionUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/decisions", &handleList);
        router.get("/api/v1/process-automation/decisions/*", &handleGet);
        router.post("/api/v1/process-automation/decisions", &handleCreate);
        router.put("/api/v1/process-automation/decisions/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/decisions/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDecisionRequest r;
        r.tenantId = tenantId;
        r.projectId = ProjectId(data.getString("projectId"));
        r.decisionId = DecisionId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.hitPolicy = data.getString("hitPolicy");
        r.version_ = data.getString("version");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = decisionUsecase.createDecision(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Decision created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto decisions = decisionUsecase.listDecisions(tenantId);

        auto jarr = Json.emptyArray;
        foreach (d; decisions) {
            jarr ~= Json.emptyObject
                .set("id", d.id)
                .set("name", d.name)
                .set("description", d.description)
                .set("status", d.status.to!string)
                .set("type", d.type.to!string)
                .set("version", d.version_)
                .set("createdAt", d.createdAt)
                .set("updatedAt", d.updatedAt);
        }

        auto resp = Json.emptyObject
            .set("count", decisions.length)
            .set("resources", jarr);

        return successResponse("Decisions retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DecisionId(precheck.id);
        if (id.isNull) 
            return errorResponse("Decision ID is required", 400);

        auto d = decisionUsecase.getDecision(tenantId, id);
        if (d.isNull)
            return errorResponse("Decision not found", 404);

        auto resp = Json.emptyObject
            .set("id", d.id)
            .set("name", d.name)
            .set("description", d.description)
            .set("status", d.status.to!string)
            .set("type", d.type.to!string)
            .set("hitPolicy", d.hitPolicy.to!string)
            .set("version", d.version_)
            .set("projectId", d.projectId)
            .set("createdBy", d.createdBy)
            .set("updatedBy", d.updatedBy)
            .set("createdAt", d.createdAt)
            .set("updatedAt", d.updatedAt);

        return successResponse("Decision retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UpdateDecisionRequest r;
        r.tenantId = tenantId;
        r.decisionId = DecisionId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.hitPolicy = data.getString("hitPolicy");
        r.version_ = data.getString("version");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = decisionUsecase.updateDecision(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Decision updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DecisionId(precheck.id);
        if (id.isNull) 
            return errorResponse("Decision ID is required", 400);

        auto result = decisionUsecase.deleteDecision(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Decision deleted successfully", "Deleted", 200, resp);
    }
}
