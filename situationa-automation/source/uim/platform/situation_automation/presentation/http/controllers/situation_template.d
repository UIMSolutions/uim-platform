/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_template;

import uim.platform.situation_automation.application.usecases.manage.situation_templates;
import uim.platform.situation_automation.application.dto;
import uim.platform.situation_automation.presentation.http.json_utils;

import uim.platform.situation_automation;

class SituationTemplateController : SAPController {
    private ManageSituationTemplatesUseCase uc;

    this(ManageSituationTemplatesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/situation-automation/templates", &handleList);
        router.get("/api/v1/situation-automation/templates/*", &handleGet);
        router.post("/api/v1/situation-automation/templates", &handleCreate);
        router.put("/api/v1/situation-automation/templates/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/templates/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateSituationTemplateRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.category = jsonStr(j, "category");
            r.defaultSeverity = jsonStr(j, "defaultSeverity");
            r.entityTypeId = jsonStr(j, "entityTypeId");
            r.sourceSystem = jsonStr(j, "sourceSystem");
            r.sourceTemplateId = jsonStr(j, "sourceTemplateId");
            r.autoResolveTimeoutMinutes = jsonInt(j, "autoResolveTimeoutMinutes");
            r.escalationEnabled = jsonBool(j, "escalationEnabled");
            r.escalationTargetUserId = jsonStr(j, "escalationTargetUserId");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation template created");
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
            auto templates = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref t; templates) {
                auto tj = Json.emptyObject;
                tj["id"] = Json(t.id);
                tj["name"] = Json(t.name);
                tj["description"] = Json(t.description);
                tj["category"] = Json(t.category.to!string);
                tj["defaultSeverity"] = Json(t.defaultSeverity.to!string);
                tj["status"] = Json(t.status.to!string);
                tj["entityTypeId"] = Json(t.entityTypeId);
                tj["sourceSystem"] = Json(t.sourceSystem);
                tj["createdBy"] = Json(t.createdBy);
                tj["createdAt"] = Json(t.createdAt);
                tj["modifiedAt"] = Json(t.modifiedAt);
                jarr ~= tj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) templates.length);
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
            auto t = uc.get_(id);
            if (t.id.length == 0) {
                writeError(res, 404, "Situation template not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(t.id);
            resp["name"] = Json(t.name);
            resp["description"] = Json(t.description);
            resp["category"] = Json(t.category.to!string);
            resp["defaultSeverity"] = Json(t.defaultSeverity.to!string);
            resp["status"] = Json(t.status.to!string);
            resp["entityTypeId"] = Json(t.entityTypeId);
            resp["sourceSystem"] = Json(t.sourceSystem);
            resp["sourceTemplateId"] = Json(t.sourceTemplateId);
            resp["autoResolveTimeoutMinutes"] = Json(cast(long) t.autoResolveTimeoutMinutes);
            resp["escalationEnabled"] = Json(t.escalationEnabled);
            resp["escalationTargetUserId"] = Json(t.escalationTargetUserId);
            resp["createdBy"] = Json(t.createdBy);
            resp["modifiedBy"] = Json(t.modifiedBy);
            resp["createdAt"] = Json(t.createdAt);
            resp["modifiedAt"] = Json(t.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateSituationTemplateRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.category = jsonStr(j, "category");
            r.defaultSeverity = jsonStr(j, "defaultSeverity");
            r.entityTypeId = jsonStr(j, "entityTypeId");
            r.autoResolveTimeoutMinutes = jsonInt(j, "autoResolveTimeoutMinutes");
            r.escalationEnabled = jsonBool(j, "escalationEnabled");
            r.escalationTargetUserId = jsonStr(j, "escalationTargetUserId");
            r.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation template updated");
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
                resp["message"] = Json("Situation template deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
