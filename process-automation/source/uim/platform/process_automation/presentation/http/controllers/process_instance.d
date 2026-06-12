/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.process_instance;
// import uim.platform.process_automation.application.usecases.manage.process_instances;
// import uim.platform.process_automation.application.dto;
import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

class ProcessInstanceController : ManageHttpController {
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

    protected Json startHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        StartProcessInstanceRequest r;
        r.tenantId = tenantId;
        r.processId = ProcessId(data.getString("processId"));
        r.processInstanceId = ProcessInstanceId(precheck.id);
        r.startedBy = UserId(data.getString("startedBy"));
        r.priority = data.getString("priority");
        r.dueDate = data.getString("dueDate");
        r.context = jsonKeyValuePairs(data, "context");

        auto result = processInstanceUsecase.startProcessInstance(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Process instance started");

        return successResponse("Process instance started successfully", "Started", 201, resp);
    }

    protected void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = startHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto instances = processInstanceUsecase.listProcessInstances(tenantId);

        auto list = Json.emptyArray;
        foreach (i; instances) {
            list ~= Json.emptyObject
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
            .set("resources", list);

        return successResponse("Process instance list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ProcessInstanceId(precheck.id);
        auto i = processInstanceUsecase.getProcessInstance(tenantId, id);
        if (i.isNull)
            return errorResponse("Process instance not found", 404);

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

        return successResponse("Process instance retrieved successfully", "Retrieved", 200, resp);
    }

    protected Json actionHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        import std.string : lastIndexOf;

        auto path = precheck.path;
        auto actionIdx = lastIndexOf(path, "/action");
        if (actionIdx < 0) {
            return errorResponse("Invalid action path", 400);
        }
        auto sub = path[0 .. actionIdx];
        auto id = extractIdFromPath(sub);

        auto data = precheck.data;
        ProcessInstanceActionRequest r;
        r.tenantId = tenantId;
        r.processInstanceId = ProcessInstanceId(id);
        r.action = data.getString("action");

        auto result = processInstanceUsecase.performProcessInstanceAction(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Action performed: " ~ r.action);
        return successResponse("Action performed successfully", "Performed", 200, resp);
    }

    protected void handleAction(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = actionHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ProcessInstanceId(precheck.id);

        auto result = processInstanceUsecase.deleteProcessInstance(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Process instance deleted");

        return successResponse("Process instance deleted successfully", "Deleted", 200, resp);
    }
}
