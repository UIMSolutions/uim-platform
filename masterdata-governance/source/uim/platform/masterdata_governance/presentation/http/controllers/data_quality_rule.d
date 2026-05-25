/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.data_quality_rule;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class DataQualityRuleController : PlatformController {
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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listDataQualityRules(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DataQualityRuleId(extractIdFromPath(path));
            auto rule = usecase.getDataQualityRule(tenantId, id);
            if (rule.isNull) { writeError(res, 404, "Data quality rule not found"); return; }
            res.writeJsonBody(rule.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DataQualityRuleDTO dto;
            dto.ruleId = DataQualityRuleId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.fieldName = j.getString("fieldName");
            dto.fieldPath = j.getString("fieldPath");
            dto.ruleType = j.getString("ruleType");
            dto.severity = j.getString("severity");
            dto.condition = j.getString("condition");
            dto.errorMessage = j.getString("errorMessage");
            dto.bpCategory = j.getString("bpCategory");
            dto.isActive = j.getBoolean("isActive");
            dto.weight = j.getInteger("weight");
            dto.validValues = j.getString("validValues");
            dto.regexPattern = j.getString("regexPattern");
            dto.minValue = j.getString("minValue");
            dto.maxValue = j.getString("maxValue");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDataQualityRule(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data quality rule created"), 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DataQualityRuleDTO dto;
            dto.ruleId = DataQualityRuleId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.condition = j.getString("condition");
            dto.errorMessage = j.getString("errorMessage");
            dto.bpCategory = j.getString("bpCategory");
            dto.isActive = j.getBoolean("isActive");
            dto.weight = j.getInteger("weight");
            dto.validValues = j.getString("validValues");
            dto.regexPattern = j.getString("regexPattern");
            dto.minValue = j.getString("minValue");
            dto.maxValue = j.getString("maxValue");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDataQualityRule(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data quality rule updated"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DataQualityRuleId(extractIdFromPath(path));
            auto result = usecase.deleteDataQualityRule(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("message", "Data quality rule deleted"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
