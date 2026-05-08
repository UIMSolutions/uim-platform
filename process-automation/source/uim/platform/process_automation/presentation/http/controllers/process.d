/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.process;

// import uim.platform.process_automation.application.processess.manage.processes;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class ProcessController : PlatformController {
    private ManageProcessesprocesses processes;

    this(ManageProcessesprocesses processes) {
        this.processes = processes;
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
            auto tenantId = req.getTenantId;

            auto j = req.json;
            CreateProcessRequest r;
            r.tenantId = tenantId;
            r.projectId = ProjectId(j.getString("projectId"));
            r.id = ProcessId(j.getString("id"));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.version_ = j.getString("version");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = processes.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process created");

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
            auto tenantId = req.getTenantId;

            auto results = processes.listProcesses(tenantId);

            auto jarr = Json.emptyArray;
            foreach (p; results) {
                jarr ~= Json.emptyObject
                    .set("id", p.id)
                    .set("name", p.name)
                    .set("description", p.description)
                    .set("status", p.status.to!string)
                    .set("category", p.category.to!string)
                    .set("version", p.version_)
                    .set("createdBy", p.createdBy)
                    .set("createdAt", p.createdAt)
                    .set("updatedAt", p.updatedAt);
            }

            auto resp = Json.emptyObject
                .set("count", results.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto id = ProcessId(extractIdFromPath(req.requestURI.to!string));
            auto p = processes.getById(tenantId, id);
            if (p.isNull) {
                writeError(res, 404, "Process not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", p.id)
                .set("name", p.name)
                .set("description", p.description)
                .set("status", p.status.to!string)
                .set("category", p.category.to!string)
                .set("version", p.version_)
                .set("projectId", p.projectId)
                .set("createdBy", p.createdBy)
                .set("updatedBy", p.updatedBy)
                .set("createdAt", p.createdAt)
                .set("updatedAt", p.updatedAt);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = req.getTenantId;

            auto j = req.json;
            UpdateProcessRequest r;
            r.tenantId = tenantId;
            r.id = ProcessId(extractIdFromPath(req.requestURI.to!string));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.version_ = j.getString("version");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = processes.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process updated");

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
            auto tenantId = req.getTenantId;

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
            r.tenantId = tenantId;
            r.processId = id;
            r.action = j.getString("action");

            auto result = processes.deploy(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process deployment action performed: " ~ r.action);

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
            auto tenantId = req.getTenantId;

            auto id = ProcessId(extractIdFromPath(req.requestURI.to!string));
            auto result = processes.deleteProcess(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
