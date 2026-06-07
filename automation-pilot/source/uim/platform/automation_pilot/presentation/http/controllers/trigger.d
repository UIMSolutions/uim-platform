/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.trigger;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class TriggerController : ManageHttpController {
    private ManageTriggersUseCase usecase;

    this(ManageTriggersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/automation-pilot/triggers", &handleList);
        router.get("/api/v1/automation-pilot/triggers/*", &handleGet);
        router.post("/api/v1/automation-pilot/triggers", &handleCreate);
        router.put("/api/v1/automation-pilot/triggers/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/triggers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listTriggers(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Trigger list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TriggerId(precheck.id);

        auto trigger = usecase.getTrigger(tenantId, id);
        if (trigger.isNull)
            return errorResponse("Trigger not found", 404);

        auto responseData = trigger.toJson();
        return successResponse("Trigger retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        TriggerDTO dto;
        dto.triggerId = TriggerId(precheck.id);
        dto.tenantId = tenantId;
        dto.commandId = data.getString("commandId");
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.eventType = data.getString("eventType");
        dto.eventSource = data.getString("eventSource");
        dto.filterExpression = data.getString("filterExpression");
        dto.inputMapping = data.getString("inputMapping");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createTrigger(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trigger created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TriggerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid trigger ID", 400);

        auto data = precheck.data;
        TriggerDTO dto;
        dto.tenantId = tenantId;
        dto.triggerId = id;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.eventType = data.getString("eventType");
        dto.eventSource = data.getString("eventSource");
        dto.filterExpression = data.getString("filterExpression");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateTrigger(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trigger updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TriggerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid trigger ID", 400);

        auto result = usecase.deleteTrigger(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trigger deleted successfully", "Deleted", 200, responseData);
    }
}
