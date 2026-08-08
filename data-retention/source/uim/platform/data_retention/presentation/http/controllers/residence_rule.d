module uim.platform.data_retention.presentation.http.controllers.residence_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ResidenceRuleController : ManageHttpController {
    private ManageResidenceRulesUseCase usecase;

    this(ManageResidenceRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/residence-rules", &handleCreate);
        router.get("/api/v1/data-retention/residence-rules", &handleList);
        router.get("/api/v1/data-retention/residence-rules/*", &handleGet);
        router.put("/api/v1/data-retention/residence-rules/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/residence-rules/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateResidenceRuleRequest r;
        r.tenantId = tenantId;
        r.purposeId = BusinessPurposeId(data.getString("businessPurposeId"));
        r.groundId = LegalGroundId(data.getString("legalGroundId"));
        r.duration = jsonInt(data, "duration");
        r.periodUnit = data.getString("periodUnit");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createResidenceRule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject
            .set("id", result.id)
            .set("businessPurposeId", r.purposeId.value)
            .set("legalGroundId", r.groundId.value)
            .set("duration", r.duration)
            .set("periodUnit", r.periodUnit)
            .set("isActive", true);

        return successResponse("Residence rule created successfully", "Created", 201, response);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listResidenceRules(tenantId);
        auto list = Json.emptyArray;
        foreach (rr; items) {
            list ~= Json.emptyObject
                .set("id", rr.id.value)
                .set("businessPurposeId", rr.businessPurposeId.value)
                .set("legalGroundId", rr.legalGroundId.value)
                .set("duration", rr.duration)
                .set("periodUnit", rr.periodUnit.to!string)
                .set("isActive", rr.isActive);
        }

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Residence rule list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ResidenceRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid residence rule ID", 400);

        auto rr = usecase.getResidenceRule(tenantId, id);
        if (rr.isNull)
            return errorResponse("Residence rule not found", 404);

        auto responseData = Json.emptyObject
            .set("id", rr.id.value)
            .set("businessPurposeId", rr.businessPurposeId.value)
            .set("legalGroundId", rr.legalGroundId.value)
            .set("duration", rr.duration)
            .set("periodUnit", rr.periodUnit.to!string)
            .set("isActive", rr.isActive);
        return successResponse("Residence rule retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ResidenceRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid residence rule ID", 400);

        auto data = precheck.data;
        UpdateResidenceRuleRequest r;
        r.tenantId = tenantId;
        r.ruleId = id;
        r.duration = jsonInt(data, "duration");
        r.periodUnit = data.getString("periodUnit");
        r.isActive = data.getBoolean("isActive", true);

        auto result = usecase.updateResidenceRule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject
            .set("id", result.id)
            .set("duration", r.duration)
            .set("periodUnit", r.periodUnit.to!string)
            .set("isActive", r.isActive);

        return successResponse("Residence rule updated successfully", "Updated", 200, response);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ResidenceRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid residence rule ID", 400);

        auto result = usecase.deleteResidenceRule(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Residence rule deleted successfully", "Deleted", 200, responseData);
    }
}
