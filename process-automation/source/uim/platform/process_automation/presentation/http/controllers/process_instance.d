/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.process_instance;

import uim.platform.process_automation.application.usecases.manage.process_instances;
import uim.platform.process_automation.application.dto;
import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

class ProcessInstanceController : PlatformController {
    private ManageProcessInstancesUseCase uc;

    this(ManageProcessInstancesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/process-automation/instances", &handleList);
        router.get("/api/v1/process-automation/instances/*", &handleGet);
        router.post("/api/v1/process-automation/instances", &handleStart);
        router.post("/api/v1/process-automation/instances/*/action", &handleAction);
        router.delete_("/api/v1/process-automation/instances/*", &handleDelete);
    }

    private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            StartProcessInstanceRequest r;
            r.tenantId = req.getTenantId;
            r.processId = j.getString("processId");
            r.id = j.getString("id");
            r.startedBy = j.getString("startedBy");
            r.priority = j.getString("priority");
            r.dueDate = jsonLong(j, "dueDate");
            r.context = jsonKeyValuePairs(j, "context");

            auto result = uc.start(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process instance started");

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
            auto instances = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (i; instances) {
                jarr ~= Json.emptyObject
                .set("id", i.id)
                .set("processId", i.processId)
                .set("processName", i.processName)
                .set("status", i.status.to!string)
                .set("priority", i.priority.to!string)
                .set("startedBy", i.startedBy)
                .set("startedAt", i.startedAt)
                .set("completedAt", i.completedAt);
            }

            auto resp = Json.emptyObject
                .set("count", instances.length)
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
            auto i = uc.getById(id);
            if (i.isNull) {
                writeError(res, 404, "Process instance not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", i.id)
                .set("processId", i.processId)
                .set("processName", i.processName)
                .set("status", i.status.to!string)
                .set("priority", i.priority.to!string)
                .set("startedBy", i.startedBy)
                .set("currentStepId", i.currentStepId)
                .set("errorMessage", i.errorMessage)
                .set("retryCount", i.retryCount)
                .set("startedAt", i.startedAt)
                .set("completedAt", i.completedAt)
                .set("dueDate", i.dueDate);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleAction(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            import std.string : lastIndexOf;

            auto path = req.requestURI.to!string;
            auto actionIdx = lastIndexOf(path, "/action");
            if (actionIdx < 0) {
                writeError(res, 400, "Invalid action path");
                return;
            }
            auto sub = path[0 .. actionIdx];
            auto id = extractIdFromPath(sub);

            auto j = req.json;
            ProcessInstanceActionRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.action = j.getString("action");

            auto result = uc.performAction(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action performed: " ~ r.action);
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
            auto result = uc.removeById(id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process instance deleted");
                    
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
