module uim.platform.data_retention.presentation.http.controllers.retention_rule;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

class RetentionRuleController : ManageHttpController {
    private ManageRetentionRulesUseCase usecase;

    this(ManageRetentionRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/retention-rules", &handleCreate);
        router.get("/api/v1/data-retention/retention-rules", &handleList);
        router.get("/api/v1/data-retention/retention-rules/*", &handleGet);
        router.put("/api/v1/data-retention/retention-rules/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/retention-rules/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateRetentionRuleRequest r;
        r.tenantId = tenantId;
        r.businessPurposeId = data.getString("businessPurposeId");
        r.legalGroundId = data.getString("legalGroundId");
        r.duration = jsonInt(j, "duration");
        r.periodUnit = data.getString("periodUnit");
        r.actionOnExpiry = data.getString("actionOnExpiry");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createRetentionRule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Retention rule created successfully", "Created", 201, responseData);

    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listRetentionRules(tenantId);
        auto jarr = Json.emptyArray;
        foreach (rr; items) {
            jarr ~= Json.emptyObject
                .set("id", rr.id.value)
                .set("businessPurposeId", rr.businessPurposeId.value)
                .set("legalGroundId", rr.legalGroundId.value)
                .set("duration", rr.duration)
                .set("periodUnit", rr.periodUnit.to!string)
                .set("isActive", rr.isActive);
        }

        auto resp = Json.emptyObject
            .set("items", jarr)
            .set("totalCount", items.length);

        return successResponse("Retention rules retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = precheck.id;
        auto rr = usecase.getRetentionRule(tenantId, id);
        if (rr.isNull)
            return errorResponse("Retention rule not found", 404);

        auto responseData = Json.emptyObject
            .set("id", rr.id.value)
            .set("businessPurposeId", rr.businessPurposeId.value)
            .set("legalGroundId", rr.legalGroundId.value)
            .set("duration", rr.duration)
            .set("periodUnit", rr.periodUnit.to!string)
            .set("actionOnExpiry", rr.actionOnExpiry.to!string)
            .set("isActive", rr.isActive);
        return successResponse("Retention rule retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = RetentionRuleId(precheck.id);
        auto data = precheck.data;
        UpdateRetentionRuleRequest r;
        r.retentionRuleId = id;
        r.tenantId = tenantId;
        r.duration = jsonInt(j, "duration");
        r.periodUnit = data.getString("periodUnit");
        r.actionOnExpiry = data.getString("actionOnExpiry");
        r.isActive = data.getBoolean("isActive", true);

        auto result = usecase.updateRetentionRule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Retention rule updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = RetentionRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid retention rule ID", 400);

        auto result = usecase.deleteRetentionRule(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Retention rule deleted successfully", "Deleted", 200, responseData);
    }
}
