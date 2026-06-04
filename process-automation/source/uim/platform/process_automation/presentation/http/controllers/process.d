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

class ProcessController : ManageHttpController {
    private ManageProcessesUseCase processUsecase;

    this(ManageProcessesUseCase processUsecase) {
        this.processUsecase = processUsecase;
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto tenantId = precheck.tenantId;

            auto data = precheck.data;
            CreateProcessRequest r;
            r.tenantId = precheck.tenantId;
            r.projectId = ProjectId(data.getString("projectId"));
            r.processId = ProcessId(precheck.id);
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.category = data.getString("category");
            r.version_ = data.getString("version");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = processUsecase.createProcess(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;


            auto results = processUsecase.listProcesses(tenantId);

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
                .set("resources", list);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto id = ProcessId(precheck.id);
            auto p = processUsecase.getProcess(tenantId, id);
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

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto tenantId = precheck.tenantId;

            auto data = precheck.data;
            UpdateProcessRequest r;
            r.tenantId = precheck.tenantId;
            r.processId = ProcessId(precheck.id);
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.category = data.getString("category");
            r.version_ = data.getString("version");
            r.updatedBy = UserId(data.getString("updatedBy"));

            auto result = processUsecase.updateProcess(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDeploy(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;

            import std.string : lastIndexOf;

            auto path = precheck.path;
            auto deployIdx = lastIndexOf(path, "/deploy");
            if (deployIdx < 0) {
                writeError(res, 400, "Invalid deploy path");
                return;
            }
            auto sub = path[0 .. deployIdx];
            auto id = extractIdFromPath(sub);

            auto data = precheck.data;
            DeployProcessRequest r;
            r.tenantId = precheck.tenantId;
            r.processId = id;
            r.action = data.getString("action");

            auto result = processUsecase.deployProcess(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process deployment action performed: " ~ r.action);

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto id = ProcessId(precheck.id);
            auto result = processUsecase.deleteProcess(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
