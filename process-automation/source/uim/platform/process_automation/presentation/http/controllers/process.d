/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.process;

import uim.platform.process_automation.application.usecases.manage.processes;
import uim.platform.process_automation.application.dto;
import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

class ProcessController : PlatformController {
    private ManageProcessesUseCase uc;

    this(ManageProcessesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/process-automation/processes", &handleList);
        router.get("/api/v1/process-automation/processes/*", &handleGet);
        router.post("/api/v1/process-automation/processes", &handleCreate);
        router.put("/api/v1/process-automation/processes/*", &handleUpdate);
        router.post("/api/v1/process-automation/processes/*/deploy", &handleDeploy);
        router.delete_("/api/v1/process-automation/processes/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateProcessRequest r;
            r.tenantId = req.getTenantId;
            r.projectId = j.getString("projectId");
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.version_ = j.getString("version");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Process created");
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
            auto processes = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (p; processes) {
                jarr ~= Json.emptyObject
                .set("id", p.id)
                .set("name", p.name)
                .set("description", p.description)
                .set("status", p.status.to!string)
                .set("category", p.category.to!string)
                .set("version", p.version_)
                .set("createdBy", p.createdBy)
                .set("createdAt", p.createdAt)
                .set("modifiedAt", p.modifiedAt);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(processes.length);
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
            auto p = uc.getById(id);
            if (p.id.isEmpty) {
                writeError(res, 404, "Process not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(p.id);
            resp["name"] = Json(p.name);
            resp["description"] = Json(p.description);
            resp["status"] = Json(p.status.to!string);
            resp["category"] = Json(p.category.to!string);
            resp["version"] = Json(p.version_);
            resp["projectId"] = Json(p.projectId);
            resp["createdBy"] = Json(p.createdBy);
            resp["modifiedBy"] = Json(p.modifiedBy);
            resp["createdAt"] = Json(p.createdAt);
            resp["modifiedAt"] = Json(p.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateProcessRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.version_ = j.getString("version");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Process updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDeploy(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            import std.string : lastIndexOf;

            auto path = req.requestURI.to!string;
            auto deployIdx = lastIndexOf(path, "/deploy");
            if (deployIdx < 0) {
                writeError(res, 400, "Invalid deploy path");
                return;
            }
            auto sub = path[0 .. deployIdx];
            auto id = extractIdFromPath(sub);

            auto j = req.json;
            DeployProcessRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.action = j.getString("action");

            auto result = uc.deploy(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Process deployment action performed: " ~ r.action);
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
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
                resp["message"] = Json("Process deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
