/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_template;

// import uim.platform.situation_automation.application.usecases.manage.situation_templates;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class SituationTemplateController : PlatformController {
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
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.defaultSeverity = j.getString("defaultSeverity");
            r.entityTypeId = j.getString("entityTypeId");
            r.sourceSystem = j.getString("sourceSystem");
            r.sourceTemplateId = j.getString("sourceTemplateId");
            r.autoResolveTimeoutMinutes = j.getInteger("autoResolveTimeoutMinutes");
            r.escalationEnabled = j.getBoolean("escalationEnabled");
            r.escalationTargetUserId = j.getString("escalationTargetUserId");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation template created");
                res.writeJsonBody(resp, 201);
            }) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto templates = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (t; templates) {
                jarr ~= Json.emptyObject
                    .set("id", t.id)
                    .set("name", t.name)
                    .set("description", t.description)
                    .set("category", t.category.to!string)
                    .set("defaultSeverity", t.defaultSeverity.to!string)
                    .set("status", t.status.to!string)
                    .set("entityTypeId", t.entityTypeId)
                    .set("sourceSystem", t.sourceSystem)
                    .set("createdBy", t.createdBy)
                    .set("createdAt", t.createdAt)
                    .set("updatedAt", t.updatedAt);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(templates.length);
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
            auto t = uc.getById(id);
            if (t.id.isEmpty) {
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
            resp["autoResolveTimeoutMinutes"] = Json(t.autoResolveTimeoutMinutes);
            resp["escalationEnabled"] = Json(t.escalationEnabled);
            resp["escalationTargetUserId"] = Json(t.escalationTargetUserId);
            resp["createdBy"] = Json(t.createdBy);
            resp["modifiedBy"] = Json(t.modifiedBy);
            resp["createdAt"] = Json(t.createdAt);
            resp["updatedAt"] = Json(t.updatedAt);
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
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.defaultSeverity = j.getString("defaultSeverity");
            r.entityTypeId = j.getString("entityTypeId");
            r.autoResolveTimeoutMinutes = j.getInteger("autoResolveTimeoutMinutes");
            r.escalationEnabled = j.getBoolean("escalationEnabled");
            r.escalationTargetUserId = j.getString("escalationTargetUserId");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation template updated");
                res.writeJsonBody(resp, 200);
            }) {
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
            }) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
