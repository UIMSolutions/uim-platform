/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.substitution_rule;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class SubstitutionRuleController : PlatformController {
    private ManageSubstitutionRulesUseCase uc;

    this(ManageSubstitutionRulesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/task-center/substitutions", &handleList);
        router.get("/api/v1/task-center/substitutions/*", &handleGet);
        router.post("/api/v1/task-center/substitutions", &handleCreate);
        router.put("/api/v1/task-center/substitutions/*", &handleUpdate);
        router.post("/api/v1/task-center/substitutions/*/activate", &handleActivate);
        router.post("/api/v1/task-center/substitutions/*/deactivate", &handleDeactivate);
        router.delete_("/api/v1/task-center/substitutions/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateSubstitutionRuleRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.userId = j.getString("userId");
            r.substituteId = j.getString("substituteId");
            r.taskDefinitionId = j.getString("taskDefinitionId");
            r.startDate = j.getString("startDate");
            r.endDate = j.getString("endDate");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Substitution rule created");
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
            auto params = req.queryParams();
            auto userId = params.get("userId", "");

            SubstitutionRule[] rules;
            if (userId.length > 0) {
                rules = uc.listByUser(tenantId, userId);
            } ) {
                rules = [];
            }

            auto jarr = Json.emptyArray;
            foreach (r; rules) {
                jarr ~= ruleToJson(r);
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
            import std.algorithm : endsWith;
            auto path = req.requestURI.to!string;
            if (path.endsWith("/activate") || path.endsWith("/deactivate")) return;

            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(path);
            auto r = uc.get_(tenantId, id);
            if (r.id.isEmpty) {
                writeError(res, 404, "Substitution rule not found");
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
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateSubstitutionRuleRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.substituteId = j.getString("substituteId");
            r.taskDefinitionId = j.getString("taskDefinitionId");
            r.startDate = j.getString("startDate");
            r.endDate = j.getString("endDate");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Substitution rule updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);
            TenantId tenantId = req.getTenantId;

            auto result = uc.activate(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Substitution rule activated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = extractIdFromPath(stripped);
            TenantId tenantId = req.getTenantId;

            auto result = uc.deactivate(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Substitution rule deactivated");
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
            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Substitution rule deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json ruleToJson(SubstitutionRule r) {
        import std.conv : to;
        auto j = Json.emptyObject;
        j["id"] = Json(r.id);
        j["tenantId"] = Json(r.tenantId);
        j["userId"] = Json(r.userId);
        j["substituteId"] = Json(r.substituteId);
        j["taskDefinitionId"] = Json(r.taskDefinitionId);
        j["status"] = Json(r.status.to!string);
        j["startDate"] = Json(r.startDate);
        j["endDate"] = Json(r.endDate);
        j["isAutoForward"] = Json(r.isAutoForward);
        j["createdBy"] = Json(r.createdBy);
        j["createdAt"] = Json(r.createdAt);
        return j;
    }
}
