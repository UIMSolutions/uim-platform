/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.decision;

// import uim.platform.process_automation.application.usecases.manage.decisions;
// import uim.platform.process_automation.application.dto;
// import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class DecisionController : PlatformController {
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
            r.tenantId = req.getTenantId;
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
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Decision created");

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
            auto decisions = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (d; decisions) {
                jarr ~= Json.emptyObject
                    .set("id", d.id)
                    .set("name", d.name)
                    .set("description", d.description)
                    .set("status", d.status.to!string)
                    .set("type", d.type.to!string)
                    .set("version", d.version_)
                    .set("createdAt", d.createdAt)
                    .set("updatedAt", d.updatedAt);
            }

            auto resp = Json.emptyObject
                .set("count", decisions.length)
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
            auto d = uc.getById(id);
            if (d.id.isEmpty) {
                writeError(res, 404, "Decision not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", d.id)
                .set("name", d.name)
                .set("description", d.description)
                .set("status", d.status.to!string)
                .set("type", d.type.to!string)
                .set("hitPolicy", d.hitPolicy.to!string)
                .set("version", d.version_)
                .set("projectId", d.projectId)
                .set("createdBy", d.createdBy)
                .set("modifiedBy", d.modifiedBy)
                .set("createdAt", d.createdAt)
                .set("updatedAt", d.updatedAt);

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
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.hitPolicy = j.getString("hitPolicy");
            r.version_ = j.getString("version");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Decision updated");

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
                  .set("message", "Decision deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
