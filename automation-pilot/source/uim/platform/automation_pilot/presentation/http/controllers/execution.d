/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.execution;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class ExecutionController : ManageHttpController {
    private ManageExecutionsUseCase executions;

    this(ManageExecutionsUseCase executions) {
        this.executions = executions;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/automation-pilot/executions", &handleList);
        router.get("/api/v1/automation-pilot/executions/*", &handleGet);
        router.post("/api/v1/automation-pilot/executions", &handleCreate);
        router.put("/api/v1/automation-pilot/executions/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/executions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = executions.listExecutions(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Execution list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ExecutionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid execution ID", 400);

        auto execution = executions.getExecution(tenantId, id);
        if (execution.isNull)
            return errorResponse("Execution not found", 404);

        auto responseData = execution.toJson();
        return successResponse("Execution retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ExecutionDTO dto;
        dto.executionId = ExecutionId(precheck.id);
        dto.tenantId = tenantId;
        dto.commandId = CommandId(data.getString("commandId"));
        dto.inputValues = data.getString("inputValues");
        dto.triggeredBy = UserId(data.getString("triggeredBy"));
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = executions.createExecution(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Execution created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ExecutionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid execution ID", 400);

        ExecutionDTO dto;
        dto.tenantId = tenantId;
        dto.executionId = id;

        auto result = executions.updateExecution(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Execution updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ExecutionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid execution ID", 400);

        auto result = executions.deleteExecution(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Execution deleted successfully", "Deleted", 200, responseData);
    }
}
