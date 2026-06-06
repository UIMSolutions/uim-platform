/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.trigger;
// import uim.platform.process_automation.application.triggerss.manage.triggers;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class TriggerController : ManageHttpController {
    private ManageTriggersUseCase triggerUsecase;

    this(ManageTriggersUseCase triggerUsecase) {
        this.triggerUsecase = triggerUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/triggers", &handleList);
        router.get("/api/v1/process-automation/triggers/*", &handleGet);
        router.post("/api/v1/process-automation/triggers", &handleCreate);
        router.put("/api/v1/process-automation/triggers/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/triggers/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateTriggerRequest r;
        r.tenantId = tenantId;
        r.processId = ProcessId(data.getString("processId"));
        r.triggerId = TriggerId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.cronExpression = data.getString("cronExpression");
        r.eventType = data.getString("eventType");
        r.eventSource = data.getString("eventSource");
        r.filterExpression = data.getString("filterExpression");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = triggerUsecase.createTrigger(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trigger created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto triggers = triggerUsecase.listTriggers(tenantId);

        auto jarr = Json.emptyArray;
        foreach (t; triggers) {
            jarr ~= Json.emptyObject
                .set("id", t.id)
                .set("name", t.name)
                .set("type", t.type.to!string)
                .set("status", t.status.to!string)
                .set("processId", t.processId)
                .set("eventType", t.eventType)
                .set("lastFiredAt", t.lastFiredAt)
                .set("fireCount", t.fireCount);
        }

        auto resp = Json.emptyObject
            .set("count", Json(triggers.length))
            .set("resources", jarr);

        return successResponse("Scan job list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = TriggerId(precheck.id);
        auto t = triggerUsecase.getTrigger(tenantId, id);
        if (t.isNull)
            return errorResponse("Trigger not found", 404);

        auto resp = Json.emptyObject
            .set("id", t.id)
            .set("name", t.name)
            .set("description", t.description)
            .set("type", t.type.to!string)
            .set("status", t.status.to!string)
            .set("processId", t.processId)
            .set("eventType", t.eventType)
            .set("eventSource", t.eventSource)
            .set("filterExpression", t.filterExpression)
            .set("createdBy", t.createdBy)
            .set("createdAt", t.createdAt)
            .set("updatedAt", t.updatedAt)
            .set("lastFiredAt", t.lastFiredAt)
            .set("fireCount", t.fireCount);

        return successResponse("Trigger retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UpdateTriggerRequest r;
        r.tenantId = tenantId;
        r.triggerId = TriggerId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.cronExpression = data.getString("cronExpression");
        r.eventType = data.getString("eventType");
        r.filterExpression = data.getString("filterExpression");

        auto result = triggerUsecase.updateTrigger(r);
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
        auto result = triggerUsecase.deleteTrigger(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trigger deleted successfully", "Deleted", 200, responseData);
    }
}
