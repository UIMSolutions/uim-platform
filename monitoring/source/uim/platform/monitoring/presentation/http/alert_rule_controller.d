module presentation.http.alert_rule_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_alert_rules;
import application.dto;
import domain.entities.alert_rule;
import domain.types;
import presentation.http.json_utils;

class AlertRuleController
{
    private ManageAlertRulesUseCase uc;

    this(ManageAlertRulesUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/alert-rules", &handleCreate);
        router.get("/api/v1/alert-rules", &handleList);
        router.get("/api/v1/alert-rules/*", &handleGetById);
        router.put("/api/v1/alert-rules/*", &handleUpdate);
        router.delete_("/api/v1/alert-rules/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateAlertRuleRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.resourceId = jsonStr(j, "resourceId");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.metricName = jsonStr(j, "metricName");
            r.metricDefinitionId = jsonStr(j, "metricDefinitionId");
            r.operator_ = jsonStr(j, "operator");
            r.warningThreshold = jsonDouble(j, "warningThreshold");
            r.criticalThreshold = jsonDouble(j, "criticalThreshold");
            r.evaluationPeriodSeconds = j.getInteger("evaluationPeriodSeconds");
            r.consecutiveBreaches = j.getInteger("consecutiveBreaches");
            r.severity = jsonStr(j, "severity");
            r.channelIds = jsonStrArray(j, "channelIds");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.createRule(r);
            if (result.success)
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
            auto rules = uc.listRules(tenantId);

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
            auto r = uc.getRule(id);
            if (r.id.length == 0)
            {
                writeError(res, 404, "Alert rule not found");
                return;
            }
            res.writeJsonBody(serializeRule(r), 200);
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
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateAlertRuleRequest r;
            r.description = jsonStr(j, "description");
            r.warningThreshold = jsonDouble(j, "warningThreshold");
            r.criticalThreshold = jsonDouble(j, "criticalThreshold");
            r.evaluationPeriodSeconds = j.getInteger("evaluationPeriodSeconds");
            r.consecutiveBreaches = j.getInteger("consecutiveBreaches");
            r.severity = jsonStr(j, "severity");
            r.isEnabled = jsonBool(j, "isEnabled", true);
            r.channelIds = jsonStrArray(j, "channelIds");

            auto result = uc.updateRule(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Alert rule not found" ? 404 : 400, result.error);
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
            auto result = uc.deleteRule(id);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["deleted"] = Json(true);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 404, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeRule(const ref AlertRule r)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(r.id);
        j["tenantId"] = Json(r.tenantId);
        j["resourceId"] = Json(r.resourceId);
        j["name"] = Json(r.name);
        j["description"] = Json(r.description);
        j["metricName"] = Json(r.metricName);
        j["metricDefinitionId"] = Json(r.metricDefinitionId);
        j["operator"] = Json(r.operator_.to!string);
        j["warningThreshold"] = Json(r.warningThreshold);
        j["criticalThreshold"] = Json(r.criticalThreshold);
        j["evaluationPeriodSeconds"] = Json(cast(long) r.evaluationPeriodSeconds);
        j["consecutiveBreaches"] = Json(cast(long) r.consecutiveBreaches);
        j["severity"] = Json(r.severity.to!string);
        j["isEnabled"] = Json(r.isEnabled);
        j["channelIds"] = toJsonArray(r.channelIds);
        j["createdBy"] = Json(r.createdBy);
        j["createdAt"] = Json(r.createdAt);
        j["updatedAt"] = Json(r.updatedAt);
        return j;
    }
}
