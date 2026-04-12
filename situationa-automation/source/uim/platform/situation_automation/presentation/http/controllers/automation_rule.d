/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.automation_rule;

// import uim.platform.situation_automation.application.usecases.manage.automation_rules;
// import uim.platform.situation_automation.application.dto;
// 
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class AutomationRuleController : PlatformController {
    private ManageAutomationRulesUseCase uc;

    this(ManageAutomationRulesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/situation-automation/rules", &handleList);
        router.get("/api/v1/situation-automation/rules/*", &handleGet);
        router.post("/api/v1/situation-automation/rules", &handleCreate);
        router.put("/api/v1/situation-automation/rules/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/rules/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateAutomationRuleRequest r;
            r.tenantId = req.getTenantId;
            r.templateId = j.getString("templateId");
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.priority = j.getString("priority");
            r.executionOrder = jsonInt(j, "executionOrder");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Automation rule created");
                res.writeJsonBody(resp, 201);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto rules = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (r; rules) {
                jarr ~= Json.emptyObject
                .set("id", r.id)
                .set("name", r.name)
                .set("templateId", r.templateId)
                .set("status", r.status.to!string)
                .set("priority", r.priority.to!string)
                .set("enabled", r.enabled)
                .set("executionOrder", r.executionOrder)
                .set("triggerCount", r.triggerCount)
                .set("successCount", r.successCount)
                .set("failureCount", r.failureCount)
                .set("createdAt", r.createdAt);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(rules.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto r = uc.get_(id);
            if (r.id.isEmpty) {
                writeError(res, 404, "Automation rule not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(r.id);
            resp["name"] = Json(r.name);
            resp["description"] = Json(r.description);
            resp["templateId"] = Json(r.templateId);
            resp["status"] = Json(r.status.to!string);
            resp["priority"] = Json(r.priority.to!string);
            resp["enabled"] = Json(r.enabled);
            resp["executionOrder"] = Json(r.executionOrder);
            resp["createdBy"] = Json(r.createdBy);
            resp["modifiedBy"] = Json(r.modifiedBy);
            resp["createdAt"] = Json(r.createdAt);
            resp["modifiedAt"] = Json(r.modifiedAt);
            resp["lastTriggeredAt"] = Json(r.lastTriggeredAt);
            resp["triggerCount"] = Json(r.triggerCount);
            resp["successCount"] = Json(r.successCount);
            resp["failureCount"] = Json(r.failureCount);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateAutomationRuleRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.priority = j.getString("priority");
            r.executionOrder = jsonInt(j, "executionOrder");
            r.enabled = j.getBoolean("enabled", true);
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Automation rule updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Automation rule deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
