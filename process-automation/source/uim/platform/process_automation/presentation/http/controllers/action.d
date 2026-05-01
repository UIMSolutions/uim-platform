/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.action;

// import uim.platform.process_automation.application.usecases.manage.actions;
// import uim.platform.process_automation.application.dto;
// import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class ActionController : PlatformController {
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
            r.tenantId = req.getTenantId;
            r.projectId = j.getString("projectId");
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.method = j.getString("method");
            r.baseUrl = j.getString("baseUrl");
            r.path = j.getString("path");
            r.authType = j.getString("authType");
            r.destinationName = j.getString("destinationName");
            r.version_ = j.getString("version");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action created");

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
                    .set("status", a.status.to!string)
                    .set("type", a.type.to!string)
                    .set("baseUrl", a.baseUrl)
                    .set("version", a.version_)
                    .set("createdAt", a.createdAt)
                    .set("updatedAt", a.updatedAt);
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
            if (!uc.existsById(id)) {
                writeError(res, 404, "Action not found");
                return;
            }

            auto a = uc.getById(id);
            auto resp = Json.emptyObject
            .set("id", a.id)
            .set("name", a.name)
            .set("description", a.description)
            .set("status", a.status.to!string)
            .set("type", a.type.to!string)
            .set("baseUrl", a.baseUrl)
            .set("path", a.path)
            .set("authType", a.authType)
            .set("destinationName", a.destinationName)
            .set("version", a.version_)
            .set("projectId", a.projectId)
            .set("createdBy", a.createdBy)
            .set("modifiedBy", a.modifiedBy)
            .set("createdAt", a.createdAt)
            .set("updatedAt", a.updatedAt);

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
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.baseUrl = j.getString("baseUrl");
            r.path = j.getString("path");
            r.authType = j.getString("authType");
            r.destinationName = j.getString("destinationName");
            r.version_ = j.getString("version");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Action updated");

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
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Action deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
