module presentation.http.validation_rule_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_validation_rules;
import application.dto;
import domain.types;
import domain.entities.validation_rule;
import presentation.http.json_utils;

class ValidationRuleController
{
    private ManageValidationRulesUseCase uc;

    this(ManageValidationRulesUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/validation-rules", &handleCreate);
        router.get("/api/v1/validation-rules", &handleList);
        router.get("/api/v1/validation-rules/*", &handleGetById);
        router.put("/api/v1/validation-rules/*", &handleUpdate);
        router.delete_("/api/v1/validation-rules/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateValidationRuleRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.datasetPattern = jsonStr(j, "datasetPattern");
            r.fieldName = jsonStr(j, "fieldName");
            r.ruleType = parseRuleType(jsonStr(j, "ruleType"));
            r.severity = parseSeverity(jsonStr(j, "severity"));
            r.pattern = jsonStr(j, "pattern");
            r.minValue = jsonStr(j, "minValue");
            r.maxValue = jsonStr(j, "maxValue");
            r.allowedValues = jsonStrArray(j, "allowedValues");
            r.expression = jsonStr(j, "expression");
            r.referenceDataset = jsonStr(j, "referenceDataset");
            r.crossFieldName = jsonStr(j, "crossFieldName");
            r.category = jsonStr(j, "category");
            r.priority = jsonInt(j, "priority");

            auto result = uc.create(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto rules = uc.listByTenant(tenantId);
            auto arr = Json.emptyArray;
            foreach (ref r; rules)
                arr ~= serializeRule(r);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) rules.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto rule = uc.getById(id);
            if (rule is null)
            {
                writeError(res, 404, "Validation rule not found");
                return;
            }
            res.writeJsonBody(serializeRule(*rule), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = UpdateValidationRuleRequest();
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.datasetPattern = jsonStr(j, "datasetPattern");
            r.fieldName = jsonStr(j, "fieldName");
            r.ruleType = parseRuleType(jsonStr(j, "ruleType"));
            r.severity = parseSeverity(jsonStr(j, "severity"));
            r.status = parseRuleStatus(jsonStr(j, "status"));
            r.pattern = jsonStr(j, "pattern");
            r.minValue = jsonStr(j, "minValue");
            r.maxValue = jsonStr(j, "maxValue");
            r.allowedValues = jsonStrArray(j, "allowedValues");
            r.expression = jsonStr(j, "expression");
            r.referenceDataset = jsonStr(j, "referenceDataset");
            r.crossFieldName = jsonStr(j, "crossFieldName");
            r.category = jsonStr(j, "category");
            r.priority = jsonInt(j, "priority");

            auto result = uc.update(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto result = uc.remove(id, tenantId);
            if (result.isSuccess())
                res.writeJsonBody(Json.emptyObject, 204);
            else
                writeError(res, 404, result.error);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeRule(ref const ValidationRule r)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(r.id);
        j["tenantId"] = Json(r.tenantId);
        j["name"] = Json(r.name);
        j["description"] = Json(r.description);
        j["datasetPattern"] = Json(r.datasetPattern);
        j["fieldName"] = Json(r.fieldName);
        j["ruleType"] = Json(r.ruleType.to!string);
        j["severity"] = Json(r.severity.to!string);
        j["status"] = Json(r.status.to!string);
        j["pattern"] = Json(r.pattern);
        j["minValue"] = Json(r.minValue);
        j["maxValue"] = Json(r.maxValue);
        j["category"] = Json(r.category);
        j["priority"] = Json(r.priority);
        j["createdAt"] = Json(r.createdAt);
        j["updatedAt"] = Json(r.updatedAt);

        if (r.allowedValues.length > 0)
        {
            auto arr = Json.emptyArray;
            foreach (v; r.allowedValues)
                arr ~= Json(v);
            j["allowedValues"] = arr;
        }

        return j;
    }

    private static RuleType parseRuleType(string s)
    {
        switch (s)
        {
            case "required":      return RuleType.required;
            case "format":        return RuleType.format_;
            case "range":         return RuleType.range;
            case "enumeration":   return RuleType.enumeration;
            case "length":        return RuleType.length;
            case "crossField":    return RuleType.crossField;
            case "custom":        return RuleType.custom;
            case "referenceData": return RuleType.referenceData;
            default:              return RuleType.required;
        }
    }

    private static RuleSeverity parseSeverity(string s)
    {
        switch (s)
        {
            case "warning":  return RuleSeverity.warning;
            case "error":    return RuleSeverity.error;
            case "critical": return RuleSeverity.critical;
            default:         return RuleSeverity.info;
        }
    }

    private static RuleStatus parseRuleStatus(string s)
    {
        switch (s)
        {
            case "active":   return RuleStatus.active;
            case "inactive": return RuleStatus.inactive;
            default:         return RuleStatus.draft;
        }
    }
}
