/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.retention_rule;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class RetentionRuleController : ManageController {
    private ManageRetentionRulesUseCase usecase;

    this(ManageRetentionRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/personal-data/retention-rules", &handleList);
        router.get("/api/v1/personal-data/retention-rules/*", &handleGet);
        router.post("/api/v1/personal-data/retention-rules", &handleCreate);
        router.put("/api/v1/personal-data/retention-rules/*", &handleUpdate);
        router.delete_("/api/v1/personal-data/retention-rules/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateRetentionRuleRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.periodUnit = j.getString("periodUnit");
            r.autoDelete = j.getBoolean("autoDelete");
            r.notifyBeforeExpiry = j.getBoolean("notifyBeforeExpiry");
            r.notifyDaysBefore = j.getString("notifyDaysBefore");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Retention rule created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto rules = usecase.list(tenantId);

            auto jarr = rules.map!(r => toJson(r)).array.toJson;

            auto resp = Json.emptyObject
                .set("count", rules.length)
                .set("resources", jarr)
                .set("message", "Retention rule list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto id = precheck.id;
            auto r = usecase.getById(tenantId, id);
            if (r.isNull) {
                writeError(res, 404, "Retention rule not found");
                return;
            }
            res.writeJsonBody(toJson(r), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto j = req.json;
            UpdateRetentionRuleRequest r;
            r.tenantId = tenantId;
            r.id = precheck.id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.periodUnit = j.getString("periodUnit");
            r.autoDelete = j.getBoolean("autoDelete");
            r.notifyBeforeExpiry = j.getBoolean("notifyBeforeExpiry");
            r.notifyDaysBefore = j.getString("notifyDaysBefore");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Retention rule updated");

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
            

            auto id = precheck.id;
            auto result = usecase.deleteRetentionRule(id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Retention rule deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json ruleToJson(RetentionRule r) {
        return Json.emptyObject
            .set("id", r.id)
            .set("name", r.name)
            .set("description", r.description)
            .set("status", r.status.to!string)
            .set("retentionPeriod", r.retentionPeriod)
            .set("periodUnit", r.periodUnit.to!string)
            .set("autoDelete", r.autoDelete)
            .set("notifyBeforeExpiry", r.notifyBeforeExpiry)
            .set("notifyDaysBefore", r.notifyDaysBefore)
            .set("createdBy", r.createdBy)
            .set("createdAt", r.createdAt);
    }
}
