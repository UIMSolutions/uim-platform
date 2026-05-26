/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.process_instance;
// import uim.platform.process_automation.application.usecases.manage.process_instances;
// import uim.platform.process_automation.application.dto;
import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class ProcessInstanceController : ManageController {
    private ManageProcessInstancesUseCase processInstanceUsecase;

    this(ManageProcessInstancesUseCase processInstanceUsecase) {
        this.processInstanceUsecase = processInstanceUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/instances", &handleList);
        router.get("/api/v1/process-automation/instances/*", &handleGet);
        router.post("/api/v1/process-automation/instances", &handleStart);
        router.post("/api/v1/process-automation/instances/*/action", &handleAction);
        router.delete_("/api/v1/process-automation/instances/*", &handleDelete);
    }

    protected void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            StartProcessInstanceRequest r;
            r.tenantId = tenantId;
            r.processId = ProcessId(j.getString("processId"));
            r.processInstanceId = ProcessInstanceId(j.getString("id"));
            r.startedBy = UserId(j.getString("startedBy"));
            r.priority = j.getString("priority");
            r.dueDate = jsonLong(j, "dueDate");
            r.context = jsonKeyValuePairs(j, "context");

            auto result = processInstanceUsecase.startProcessInstance(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process instance started");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto instances = processInstanceUsecase.listProcessInstances(tenantId);

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

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = req.getTenantId;

            auto id = ProcessInstanceprecheck.id);
            auto i = processInstanceUsecase.getProcessInstance(tenantId, id);
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

    protected void handleAction(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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
            r.tenantId = tenantId;
            r.processInstanceId = ProcessInstanceId(id);
            r.action = j.getString("action");

            auto result = processInstanceUsecase.performProcessInstanceAction(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action performed: " ~ r.action);
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ProcessInstanceprecheck.id);
            
            auto result = processInstanceUsecase.deleteProcessInstance(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Process instance deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
