/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.data_quality_rule;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class DataQualityRuleController : ManageHttpController {
    private ManageDataQualityRulesUseCase usecase;

    this(ManageDataQualityRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/masterdata-governance/data-quality-rules", &handleList);
        router.get("/api/v1/masterdata-governance/data-quality-rules/*", &handleGet);
        router.post("/api/v1/masterdata-governance/data-quality-rules", &handleCreate);
        router.put("/api/v1/masterdata-governance/data-quality-rules/*", &handleUpdate);
        router.delete_("/api/v1/masterdata-governance/data-quality-rules/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDataQualityRules(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Data quality rules list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DataQualityRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data quality rule ID", 400);

        auto rule = usecase.getDataQualityRule(tenantId, id);
        if (rule.isNull)
            return errorResponse("Data quality rule not found", 404);

        auto responseData = rule.toJson();
        return successResponse("Data quality rule retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        DataQualityRuleDTO dto;
        dto.tenantId = precheck.tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.fieldName = data.getString("fieldName");
        dto.fieldPath = data.getString("fieldPath");
        dto.ruleType = data.getString("ruleType");
        dto.severity = data.getString("severity");
        dto.condition = data.getString("condition");
        dto.errorMessage = data.getString("errorMessage");
        dto.bpCategory = data.getString("bpCategory");
        dto.isActive = data.getBoolean("isActive");
        dto.weight = data.getInteger("weight");
        dto.validValues = data.getString("validValues");
        dto.regexPattern = data.getString("regexPattern");
        dto.minValue = data.getString("minValue");
        dto.maxValue = data.getString("maxValue");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDataQualityRule(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data quality rule created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DataQualityRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data quality rule ID", 400);

        auto data = precheck.data;
        DataQualityRuleDTO dto;
        dto.ruleId = DataQualityRuleId(precheck.id);
        dto.tenantId = precheck.tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.condition = data.getString("condition");
        dto.errorMessage = data.getString("errorMessage");
        dto.bpCategory = data.getString("bpCategory");
        dto.isActive = data.getBoolean("isActive");
        dto.weight = data.getInteger("weight");
        dto.validValues = data.getString("validValues");
        dto.regexPattern = data.getString("regexPattern");
        dto.minValue = data.getString("minValue");
        dto.maxValue = data.getString("maxValue");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDataQualityRule(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data quality rule updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataQualityRuleId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data quality rule ID", 400);

        auto result = usecase.deleteDataQualityRule(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data quality rule deleted successfully", "Deleted", 200, responseData);
    }
}
