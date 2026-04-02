module uim.platform.data-quality.presentation.http.controllers.validate_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.validate_data;
import application.dto;
import domain.types;
import domain.entities.validation_result;
import presentation.http.json_utils;

class ValidateController
{
    private ValidateDataUseCase uc;

    this(ValidateDataUseCase uc)
    {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/validate", &handleValidate);
        router.post("/api/v1/validate/batch", &handleValidateBatch);
        router.get("/api/v1/validate/results/*", &handleGetResult);
    }

    private void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = ValidateRecordRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.datasetId = j.getString("datasetId");
            r.recordId = j.getString("recordId");
            r.fieldValues = jsonStrMap(j, "fieldValues");

            auto result = uc.validateRecord(r);
            res.writeJsonBody(serializeResult(result), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleValidateBatch(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = ValidateBatchRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.datasetId = j.getString("datasetId");

            auto recordsJson = "records" in j;
            if (recordsJson !is null && (*recordsJson).type == Json.Type.array)
            {
                foreach (item; *recordsJson)
                {
                    if (item.type == Json.Type.object)
                    {
                        RecordFieldValues rfv;
                        rfv.recordId = item.getString("recordId");
                        rfv.fieldValues = jsonStrMap(item, "fieldValues");
                        r.records ~= rfv;
                    }
                }
            }

            auto results = uc.validateBatch(r);
            auto arr = Json.emptyArray;
            foreach (ref res_; results)
                arr ~= serializeResult(res_);

            auto resp = Json.emptyObject;
            resp["results"] = arr;
            resp["totalCount"] = Json(cast(long) results.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetResult(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto recordId = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto result = uc.getResultByRecord(recordId, tenantId);
            if (result is null)
            {
                writeError(res, 404, "Validation result not found");
                return;
            }
            res.writeJsonBody(serializeResult(*result), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeResult(ref const ValidationResult r)
    {
        auto j = Json.emptyObject;
        j["recordId"] = Json(r.recordId);
        j["tenantId"] = Json(r.tenantId);
        j["datasetId"] = Json(r.datasetId);
        j["totalRulesChecked"] = Json(r.totalRulesChecked);
        j["passedRules"] = Json(r.passedRules);
        j["failedRules"] = Json(r.failedRules);
        j["qualityScore"] = Json(r.qualityScore);
        j["validatedAt"] = Json(r.validatedAt);

        if (r.violations.length > 0)
        {
            auto violations = Json.emptyArray;
            foreach (ref v; r.violations)
            {
                auto vj = Json.emptyObject;
                vj["ruleId"] = Json(v.ruleId);
                vj["ruleName"] = Json(v.ruleName);
                vj["fieldName"] = Json(v.fieldName);
                vj["fieldValue"] = Json(v.fieldValue);
                vj["severity"] = Json(v.severity.to!string);
                vj["message"] = Json(v.message);
                if (v.suggestedValue.length > 0)
                    vj["suggestedValue"] = Json(v.suggestedValue);
                violations ~= vj;
            }
            j["violations"] = violations;
        }

        return j;
    }
}
