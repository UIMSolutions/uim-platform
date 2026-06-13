/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.scheduled_execution;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class ScheduledExecutionController : ManageHttpController {
    private ManageScheduledExecutionsUseCase scheduledExecutions;

    this(ManageScheduledExecutionsUseCase scheduledExecutions) {
        this.scheduledExecutions = scheduledExecutions;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/automation-pilot/scheduled-executions", &handleList);
        router.get("/api/v1/automation-pilot/scheduled-executions/*", &handleGet);
        router.post("/api/v1/automation-pilot/scheduled-executions", &handleCreate);
        router.put("/api/v1/automation-pilot/scheduled-executions/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/scheduled-executions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = scheduledExecutions.listScheduledExecutions(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Scheduled execution list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ScheduledExecutionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid scheduled execution ID", 400);

        auto execution = scheduledExecutions.getScheduledExecution(tenantId, id);
        if (execution.isNull)
            return errorResponse("Scheduled execution not found", 404);

        auto responseData = execution.toJson();
        return successResponse("Scheduled execution retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        ;

        auto data = precheck.data;
        ScheduledExecutionDTO dto;
        dto.tenantId = tenantId;
        dto.executionId = ScheduledExecutionId(precheck.id);
        dto.commandId = CommandId(data.getString("commandId"));
        dto.cronExpression = data.getString("cronExpression");
        dto.scheduledAt = data.getLong("scheduledAt");
        dto.inputValues = data.getString("inputValues");
        dto.description = data.getString("description");
        dto.maxRetries = data.getString("maxRetries");
        dto.retryDelay = data.getString("retryDelay");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = scheduledExecutions.createScheduledExecution(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Scheduled execution created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScheduledExecutionDTO dto;
        dto.tenantId = tenantId;
        dto.executionId = ScheduledExecutionId(precheck.id);
        dto.cronExpression = data.getString("cronExpression");
        dto.scheduledAt = data.getLong("scheduledAt");
        dto.description = data.getString("description");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = scheduledExecutions.updateScheduledExecution(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Scheduled execution updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ScheduledExecutionId(precheck.id);

        auto result = scheduledExecutions.deleteScheduledExecution(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Scheduled execution deleted successfully", "Deleted", 200, responseData);
    }
}
