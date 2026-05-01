/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_action;
// 
// import uim.platform.situation_automation.application.usecases.manage.situation_actions;
// import uim.platform.situation_automation.application.dto;
// 
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class SituationActionController : PlatformController {
    private ManageSituationActionsUseCase uc;

    this(ManageSituationActionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/situation-automation/actions", &handleList);
        router.get("/api/v1/situation-automation/actions/*", &handleGet);
        router.post("/api/v1/situation-automation/actions", &handleCreate);
        router.put("/api/v1/situation-automation/actions/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/actions/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateSituationActionRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.baseUrl = j.getString("baseUrl");
            r.path = j.getString("path");
            r.method = j.getString("method");
            r.authType = j.getString("authType");
            r.destinationName = j.getString("destinationName");
            r.webhookUrl = j.getString("webhookUrl");
            r.emailTemplate = j.getString("emailTemplate");
            r.scriptContent = j.getString("scriptContent");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation action created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto actions = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (a; actions) {
                jarr ~= Json.emptyObject
                .set("id", a.id)
                .set("name", a.name)
                .set("description", a.description)
                .set("type", a.type.to!string)
                .set("status", a.status.to!string)
                .set("lastExecutedAt", a.lastExecutedAt)
                .set("executionCount", a.executionCount)
                .set("createdAt", a.createdAt);
            }

            auto resp = Json.emptyObject
                .set("count", actions.length)
                .set("resources", jarr);
                
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto a = uc.getById(id);
            if (a.isNull) {
                writeError(res, 404, "Situation action not found");
                return;
            }

            auto apiCfg = Json.emptyObject
                .set("baseUrl", a.apiConfig.baseUrl)
                .set("path", a.apiConfig.path)
                .set("authType", a.apiConfig.authType)
                .set("destinationName", a.apiConfig.destinationName);

            auto resp = Json.emptyObject
                .set("id", a.id)
                .set("name", a.name)
                .set("description", a.description)
                .set("type", a.type.to!string)
                .set("status", a.status.to!string)
                .set("webhookUrl", a.webhookUrl)
                .set("emailTemplate", a.emailTemplate)
                .set("createdBy", a.createdBy)
                .set("updatedBy", a.updatedBy)
                .set("createdAt", a.createdAt)
                .set("updatedAt", a.updatedAt)
                .set("lastExecutedAt", a.lastExecutedAt)
                .set("executionCount", a.executionCount)
                .set("apiConfig", apiCfg);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateSituationActionRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.baseUrl = j.getString("baseUrl");
            r.path = j.getString("path");
            r.authType = j.getString("authType");
            r.destinationName = j.getString("destinationName");
            r.webhookUrl = j.getString("webhookUrl");
            r.emailTemplate = j.getString("emailTemplate");
            r.updatedBy = j.getString("updatedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation action updated");

                res.writeJsonBody(resp, 200);
            } else {
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
            auto result = uc.removeById(id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation action deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
