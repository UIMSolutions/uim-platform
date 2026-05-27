/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.data_quality_rule;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class DataQualityRuleController : ManageController {
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = DataQualityRuleId(precheck.id);
            auto rule = usecase.getDataQualityRule(tenantId, id);
            if (rule.isNull) { writeError(res, 404, "Data quality rule not found"); return; }
            res.writeJsonBody(rule.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            DataQualityRuleDTO dto;
            dto.ruleId = DataQualityRuleId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.fieldName = data.getString("fieldName");
            dto.fieldPath = data.getString("fieldPath");
            dto.ruleType = data.getString("ruleType");
            dto.severity = data.getString("severity");
            dto.condition = data.getString("condition");
            dto.errorMessage = data.getString("errorMessage");
            dto.bpCategory = data.getString("bpCategory");
            dto.isActive = j.getBoolean("isActive");
            dto.weight = j.getInteger("weight");
            dto.validValues = data.getString("validValues");
            dto.regexPattern = data.getString("regexPattern");
            dto.minValue = data.getString("minValue");
            dto.maxValue = data.getString("maxValue");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createDataQualityRule(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            DataQualityRuleDTO dto;
            dto.ruleId = DataQualityRuleId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.condition = data.getString("condition");
            dto.errorMessage = data.getString("errorMessage");
            dto.bpCategory = data.getString("bpCategory");
            dto.isActive = j.getBoolean("isActive");
            dto.weight = j.getInteger("weight");
            dto.validValues = data.getString("validValues");
            dto.regexPattern = data.getString("regexPattern");
            dto.minValue = data.getString("minValue");
            dto.maxValue = data.getString("maxValue");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateDataQualityRule(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = DataQualityRuleId(precheck.id);
            auto result = usecase.deleteDataQualityRule(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("message", "Data quality rule deleted"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
