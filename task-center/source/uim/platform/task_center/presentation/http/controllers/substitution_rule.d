/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.substitution_rule;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class SubstitutionRuleController : ManageHttpController {
    private ManageSubstitutionRulesUseCase usecase;

    this(ManageSubstitutionRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/substitutions", &handleList);
        router.get("/api/v1/task-center/substitutions/*", &handleGet);
        router.post("/api/v1/task-center/substitutions", &handleCreate);
        router.put("/api/v1/task-center/substitutions/*", &handleUpdate);
        router.post("/api/v1/task-center/substitutions/*/activate", &handleActivate);
        router.post("/api/v1/task-center/substitutions/*/deactivate", &handleDeactivate);
        router.delete_("/api/v1/task-center/substitutions/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateSubstitutionRuleRequest r;
        r.tenantId = tenantId;
        r.id = SubstitutionRuleId(precheck.id);
        r.userId = UserId(data.getString("userId"));
        r.substituteId = UserId(data.getString("substituteId"));
        r.taskDefinitionId = data.getString("taskDefinitionId");
        r.startDate = data.getString("startDate");
        r.endDate = data.getString("endDate");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createSubstitutionRule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Substitution rule created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto params = req.queryParams();
        auto userId = UserId(params.get("userId", ""));

        SubstitutionRule[] rules;
        if (!userId.isEmpty)
            rules = usecase.listByUser(tenantId, userId);

        auto list = rules.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Substitution rule list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        if (path.endsWith("/activate") || path.endsWith("/deactivate"))
            return errorResponse("Not found", 404);

        auto tenantId = precheck.tenantId;
        auto id = SubstitutionRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid substitution rule ID", 400);

        auto r = usecase.getById(tenantId, id);
        if (item.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = item.toJson();
        return successResponse("Substitution rule retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SubstitutionRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid substitution rule ID", 400);

        auto data = precheck.data;
        UpdateSubstitutionRuleRequest r;
        r.tenantId = tenantId;
        r.ruleId = id;
        r.substituteId = UserId(data.getString("substituteId"));
        r.taskDefinitionId = data.getString("taskDefinitionId");
        r.startDate = data.getString("startDate");
        r.endDate = data.getString("endDate");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateSubstitutionRule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Substitution rule updated successfully", "Updated", 200, responseData);
    }

    protected Json activateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 9]; // remove "/activate"
        auto id = SubstitutionRuleId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid substitution rule ID", 400);

        auto result = usecase.activateSubstitutionRule(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Substitution rule activated successfully", "Updated", 200, responseData);
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = activateHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json deactivateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
        auto id = SubstitutionRuleId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid substitution rule ID", 400);

        auto result = usecase.deactivateSubstitutionRule(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Substitution rule deactivated successfully", "Updated", 200, responseData);
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = deactivateHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SubstitutionRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid substitution rule ID", 400);

        auto result = usecase.deleteSubstitutionRule(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Substitution rule deleted successfully", "Deleted", 200, responseData);
    }
}
