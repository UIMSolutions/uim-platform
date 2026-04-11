/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.retention_rule;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class RetentionRuleController : PlatformController {
    private ManageRetentionRulesUseCase uc;

    this(ManageRetentionRulesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/personal-data/retention-rules", &handleList);
        router.get("/api/v1/personal-data/retention-rules/*", &handleGet);
        router.post("/api/v1/personal-data/retention-rules", &handleCreate);
        router.put("/api/v1/personal-data/retention-rules/*", &handleUpdate);
        router.delete_("/api/v1/personal-data/retention-rules/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateRetentionRuleRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.periodUnit = j.getString("periodUnit");
            r.autoDelete = jsonBool(j, "autoDelete");
            r.notifyBeforeExpiry = jsonBool(j, "notifyBeforeExpiry");
            r.notifyDaysBefore = j.getString("notifyDaysBefore");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Retention rule created");
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
                jarr ~= ruleToJson(r);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) rules.length);
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
                writeError(res, 404, "Retention rule not found");
                return;
            }
            res.writeJsonBody(ruleToJson(r), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateRetentionRuleRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.periodUnit = j.getString("periodUnit");
            r.autoDelete = jsonBool(j, "autoDelete");
            r.notifyBeforeExpiry = jsonBool(j, "notifyBeforeExpiry");
            r.notifyDaysBefore = j.getString("notifyDaysBefore");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Retention rule updated");
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
                resp["message"] = Json("Retention rule deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json ruleToJson(RetentionRule r) {
        auto j = Json.emptyObject;
        j["id"] = Json(r.id);
        j["name"] = Json(r.name);
        j["description"] = Json(r.description);
        j["status"] = Json(r.status.to!string);
        j["retentionPeriod"] = Json(r.retentionPeriod);
        j["periodUnit"] = Json(r.periodUnit.to!string);
        j["autoDelete"] = Json(r.autoDelete);
        j["notifyBeforeExpiry"] = Json(r.notifyBeforeExpiry);
        j["notifyDaysBefore"] = Json(r.notifyDaysBefore);
        j["createdBy"] = Json(r.createdBy);
        j["createdAt"] = Json(r.createdAt);
        return j;
    }
}
