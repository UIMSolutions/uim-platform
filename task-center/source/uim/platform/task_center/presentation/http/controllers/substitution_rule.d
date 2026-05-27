/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.substitution_rule;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class SubstitutionRuleController : ManageController {
    private ManageSubstitutionRulesUseCase usecase;

    this(ManageSubstitutionRulesUseCase usecase) {
        this.usecase = usecase;
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            CreateSubstitutionRuleRequest r;
            r.tenantId = tenantId;
            r.id = precheck.id;
            r.userId = UserId(data.getString("userId"));
            r.substituteId = UserId(data.getString("substituteId"));
            r.taskDefinitionId = data.getString("taskDefinitionId");
            r.startDate = data.getString("startDate");
            r.endDate = data.getString("endDate");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createSubstitutionRule(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Substitution rule created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto params = req.queryParams();
            auto userId = UserId(params.get("userId", ""));

            SubstitutionRule[] rules;
            if (!userId.isEmpty)
                rules = usecase.listByUser(tenantId, userId);

            auto jarr = rules.map!(r => toJson(r)).array.toJson;

            auto resp = Json.emptyObject
                .set("count", rules.length)
                .set("resources", jarr)
                .set("message", "Substitution rules retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            import std.algorithm : endsWith;

            auto path = req.requestURI.to!string;
            if (path.endsWith("/activate") || path.endsWith("/deactivate"))
                return;

            auto tenantId = precheck.tenantId;
            auto id = extractIdFromPath(path);
            auto r = usecase.getById(tenantId, id);
            if (r.isNull) {
                writeError(res, 404, "Substitution rule not found");
                return;
            }
            res.writeJsonBody(toJson(r), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;

            auto id = SubstitutionRuleprecheck.id);
            auto data = precheck.data;
            UpdateSubstitutionRuleRequest r;
            r.tenantId = tenantId;
            r.id = id;
            r.substituteId = UserId(data.getString("substituteId"));
            r.taskDefinitionId = data.getString("taskDefinitionId");
            r.startDate = data.getString("startDate");
            r.endDate = data.getString("endDate");
            r.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateSubstitutionRule(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Substitution rule updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto path = req.requestURI.to!string;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = SubstitutionRuleId(extractIdFromPath(stripped));
            auto tenantId = precheck.tenantId;

            auto result = usecase.activateSubstitutionRule(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Substitution rule activated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = SubstitutionRuleId(extractIdFromPath(stripped));

            auto result = usecase.deactivateSubstitutionRule(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Substitution rule deactivated");

                res.writeJsonBody(resp, 200);
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
            auto id = SubstitutionRuleprecheck.id);
            auto result = usecase.deleteSubstitutionRule(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Substitution rule deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
