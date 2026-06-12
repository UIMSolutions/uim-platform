/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.automation;
// import uim.platform.process_automation.application.usecases.manage.automations;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

class AutomationController : ManageHttpController {
    private ManageAutomationsUseCase automationUsecase;

    this(ManageAutomationsUseCase automationUsecase) {
        this.automationUsecase = automationUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/automations", &handleList);
        router.get("/api/v1/process-automation/automations/*", &handleGet);
        router.post("/api/v1/process-automation/automations", &handleCreate);
        router.put("/api/v1/process-automation/automations/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/automations/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateAutomationRequest r;
        r.tenantId = tenantId;
        r.projectId = ProjectId(data.getString("projectId"));
        r.automationId = AutomationId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.targetApplication = data.getString("targetApplication");
        r.version_ = data.getString("version");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = automationUsecase.createAutomation(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Automation created");

        return successResponse("Automation created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto automations = automationUsecase.listAutomations(tenantId);

        auto list = Json.emptyArray;
        foreach (a; automations) {
            list ~= Json.emptyObject
                .set("id", a.id)
                .set("name", a.name)
                .set("description", a.description)
                .set("status", a.status.to!string)
                .set("type", a.type.to!string)
                .set("targetApplication", a.targetApplication)
                .set("version", a.version_)
                .set("createdAt", a.createdAt)
                .set("updatedAt", a.updatedAt);
        }

        auto resp = Json.emptyObject
            .set("count", automations.length)
            .set("resources", list);

        return successResponse("Automations retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = AutomationId(precheck.id);

        auto a = automationUsecase.getAutomation(tenantId, id);
        if (a.isNull) {
            return errorResponse("Automation not found", 404);
        }

        auto resp = Json.emptyObject
            .set("id", a.id)
            .set("name", a.name)
            .set("description", a.description)
            .set("status", a.status.to!string)
            .set("type", a.type.to!string)
            .set("targetApplication", a.targetApplication)
            .set("version", a.version_)
            .set("projectId", a.projectId)
            .set("createdBy", a.createdBy)
            .set("updatedBy", a.updatedBy)
            .set("createdAt", a.createdAt)
            .set("updatedAt", a.updatedAt);

        return successResponse("Automation retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UpdateAutomationRequest r;
        r.tenantId = tenantId;
        r.automationId = AutomationId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.targetApplication = data.getString("targetApplication");
        r.version_ = data.getString("version");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = automationUsecase.updateAutomation(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Automation updated");

        return successResponse("Automation updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = AutomationId(precheck.id);
        auto result = automationUsecase.deleteAutomation(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Automation deleted");

        return successResponse("Automation deleted successfully", "Deleted", 200, resp);
    }
}
