/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_action;
// 
// import uim.platform.situation_automation.application.usecases.manage.situation_actions;
// import uim.platform.situation_automation.application.dto;
// import uim.platform.situation_automation.presentation.http.json_utils;
// 
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class SituationActionController : SAPController {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.type = jsonStr(j, "type");
            r.baseUrl = jsonStr(j, "baseUrl");
            r.path = jsonStr(j, "path");
            r.method = jsonStr(j, "method");
            r.authType = jsonStr(j, "authType");
            r.destinationName = jsonStr(j, "destinationName");
            r.webhookUrl = jsonStr(j, "webhookUrl");
            r.emailTemplate = jsonStr(j, "emailTemplate");
            r.scriptContent = jsonStr(j, "scriptContent");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation action created");
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto actions = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref a; actions) {
                auto aj = Json.emptyObject;
                aj["id"] = Json(a.id);
                aj["name"] = Json(a.name);
                aj["description"] = Json(a.description);
                aj["type"] = Json(a.type.to!string);
                aj["status"] = Json(a.status.to!string);
                aj["lastExecutedAt"] = Json(a.lastExecutedAt);
                aj["executionCount"] = Json(a.executionCount);
                aj["createdAt"] = Json(a.createdAt);
                jarr ~= aj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) actions.length);
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
            auto a = uc.get_(id);
            if (a.id.length == 0) {
                writeError(res, 404, "Situation action not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(a.id);
            resp["name"] = Json(a.name);
            resp["description"] = Json(a.description);
            resp["type"] = Json(a.type.to!string);
            resp["status"] = Json(a.status.to!string);
            resp["webhookUrl"] = Json(a.webhookUrl);
            resp["emailTemplate"] = Json(a.emailTemplate);
            resp["createdBy"] = Json(a.createdBy);
            resp["modifiedBy"] = Json(a.modifiedBy);
            resp["createdAt"] = Json(a.createdAt);
            resp["modifiedAt"] = Json(a.modifiedAt);
            resp["lastExecutedAt"] = Json(a.lastExecutedAt);
            resp["executionCount"] = Json(a.executionCount);

            auto apiCfg = Json.emptyObject;
            apiCfg["baseUrl"] = Json(a.apiConfig.baseUrl);
            apiCfg["path"] = Json(a.apiConfig.path);
            apiCfg["authType"] = Json(a.apiConfig.authType);
            apiCfg["destinationName"] = Json(a.apiConfig.destinationName);
            resp["apiConfig"] = apiCfg;

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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.baseUrl = jsonStr(j, "baseUrl");
            r.path = jsonStr(j, "path");
            r.authType = jsonStr(j, "authType");
            r.destinationName = jsonStr(j, "destinationName");
            r.webhookUrl = jsonStr(j, "webhookUrl");
            r.emailTemplate = jsonStr(j, "emailTemplate");
            r.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation action updated");
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation action deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
