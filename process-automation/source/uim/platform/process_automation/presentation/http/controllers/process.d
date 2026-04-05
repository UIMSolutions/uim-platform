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

class ProcessController : SAPController {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.projectId = jsonStr(j, "projectId");
            r.id = jsonStr(j, "id");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.category = jsonStr(j, "category");
            r.version_ = jsonStr(j, "version");
            r.createdBy = jsonStr(j, "createdBy");

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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto processes = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref p; processes) {
                auto pj = Json.emptyObject;
                pj["id"] = Json(p.id);
                pj["name"] = Json(p.name);
                pj["description"] = Json(p.description);
                pj["status"] = Json(p.status.to!string);
                pj["category"] = Json(p.category.to!string);
                pj["version"] = Json(p.version_);
                pj["createdBy"] = Json(p.createdBy);
                pj["createdAt"] = Json(p.createdAt);
                pj["modifiedAt"] = Json(p.modifiedAt);
                jarr ~= pj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) processes.length);
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
            auto p = uc.get_(id);
            if (p.id.length == 0) {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.category = jsonStr(j, "category");
            r.version_ = jsonStr(j, "version");
            r.modifiedBy = jsonStr(j, "modifiedBy");

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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = id;
            r.action = jsonStr(j, "action");

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
