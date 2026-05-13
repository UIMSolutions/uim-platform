/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.automation;

// import uim.platform.process_automation.application.usecases.manage.automations;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class AutomationController : PlatformController {
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

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            CreateAutomationRequest r;
            r.tenantId = tenantId;
            r.projectId = ProjectId(j.getString("projectId"));
            r.automationId = AutomationId(j.getString("id"));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.targetApplication = j.getString("targetApplication");
            r.version_ = j.getString("version");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = automationUsecase.createAutomation(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Automation created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto automations = automationUsecase.listAutomations(tenantId);

            auto jarr = Json.emptyArray;
            foreach (a; automations) {
                jarr ~= Json.emptyObject
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
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = req.getTenantId;

            auto id = AutomationId(extractIdFromPath(req.requestURI.to!string));
            
            auto a = automationUsecase.getAutomation(tenantId, id);
            if (a.isNull) {
                writeError(res, 404, "Automation not found");
                return;
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

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            UpdateAutomationRequest r;
            r.tenantId = tenantId;
            r.automationId = AutomationId(extractIdFromPath(req.requestURI.to!string));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.targetApplication = j.getString("targetApplication");
            r.version_ = j.getString("version");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = automationUsecase.updateAutomation(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Automation updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = req.getTenantId;

            auto id = AutomationId(extractIdFromPath(req.requestURI.to!string));
            auto result = automationUsecase.deleteAutomation(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Automation deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
