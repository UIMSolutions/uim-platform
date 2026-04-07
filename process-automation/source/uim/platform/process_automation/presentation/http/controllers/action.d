/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.action;

import uim.platform.process_automation.application.usecases.manage.actions;
import uim.platform.process_automation.application.dto;
import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

class ActionController : SAPController {
    private ManageActionsUseCase uc;

    this(ManageActionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/process-automation/actions", &handleList);
        router.get("/api/v1/process-automation/actions/*", &handleGet);
        router.post("/api/v1/process-automation/actions", &handleCreate);
        router.put("/api/v1/process-automation/actions/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/actions/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateActionRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.projectId = jsonStr(j, "projectId");
            r.id = jsonStr(j, "id");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.type = jsonStr(j, "type");
            r.method = jsonStr(j, "method");
            r.baseUrl = jsonStr(j, "baseUrl");
            r.path = jsonStr(j, "path");
            r.authType = jsonStr(j, "authType");
            r.destinationName = jsonStr(j, "destinationName");
            r.version_ = jsonStr(j, "version");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Action created");
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
            auto actions = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref a; actions) {
                auto aj = Json.emptyObject;
                aj["id"] = Json(a.id);
                aj["name"] = Json(a.name);
                aj["description"] = Json(a.description);
                aj["status"] = Json(a.status.to!string);
                aj["type"] = Json(a.type.to!string);
                aj["baseUrl"] = Json(a.baseUrl);
                aj["version"] = Json(a.version_);
                aj["createdAt"] = Json(a.createdAt);
                aj["modifiedAt"] = Json(a.modifiedAt);
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
                writeError(res, 404, "Action not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(a.id);
            resp["name"] = Json(a.name);
            resp["description"] = Json(a.description);
            resp["status"] = Json(a.status.to!string);
            resp["type"] = Json(a.type.to!string);
            resp["baseUrl"] = Json(a.baseUrl);
            resp["path"] = Json(a.path);
            resp["authType"] = Json(a.authType);
            resp["destinationName"] = Json(a.destinationName);
            resp["version"] = Json(a.version_);
            resp["projectId"] = Json(a.projectId);
            resp["createdBy"] = Json(a.createdBy);
            resp["modifiedBy"] = Json(a.modifiedBy);
            resp["createdAt"] = Json(a.createdAt);
            resp["modifiedAt"] = Json(a.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateActionRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.baseUrl = jsonStr(j, "baseUrl");
            r.path = jsonStr(j, "path");
            r.authType = jsonStr(j, "authType");
            r.destinationName = jsonStr(j, "destinationName");
            r.version_ = jsonStr(j, "version");
            r.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Action updated");
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
                resp["message"] = Json("Action deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
