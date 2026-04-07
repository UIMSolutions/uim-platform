/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.decision;

import uim.platform.process_automation.application.usecases.manage.decisions;
import uim.platform.process_automation.application.dto;
import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

class DecisionController : SAPController {
    private ManageDecisionsUseCase uc;

    this(ManageDecisionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/process-automation/decisions", &handleList);
        router.get("/api/v1/process-automation/decisions/*", &handleGet);
        router.post("/api/v1/process-automation/decisions", &handleCreate);
        router.put("/api/v1/process-automation/decisions/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/decisions/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDecisionRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.projectId = j.getString("projectId");
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.hitPolicy = j.getString("hitPolicy");
            r.version_ = j.getString("version");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Decision created");
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto decisions = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref d; decisions) {
                auto dj = Json.emptyObject;
                dj["id"] = Json(d.id);
                dj["name"] = Json(d.name);
                dj["description"] = Json(d.description);
                dj["status"] = Json(d.status.to!string);
                dj["type"] = Json(d.type.to!string);
                dj["version"] = Json(d.version_);
                dj["createdAt"] = Json(d.createdAt);
                dj["modifiedAt"] = Json(d.modifiedAt);
                jarr ~= dj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) decisions.length);
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
            auto d = uc.get_(id);
            if (d.id.length == 0) {
                writeError(res, 404, "Decision not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(d.id);
            resp["name"] = Json(d.name);
            resp["description"] = Json(d.description);
            resp["status"] = Json(d.status.to!string);
            resp["type"] = Json(d.type.to!string);
            resp["hitPolicy"] = Json(d.hitPolicy.to!string);
            resp["version"] = Json(d.version_);
            resp["projectId"] = Json(d.projectId);
            resp["createdBy"] = Json(d.createdBy);
            resp["modifiedBy"] = Json(d.modifiedBy);
            resp["createdAt"] = Json(d.createdAt);
            resp["modifiedAt"] = Json(d.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateDecisionRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.hitPolicy = j.getString("hitPolicy");
            r.version_ = j.getString("version");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Decision updated");
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
                resp["message"] = Json("Decision deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
