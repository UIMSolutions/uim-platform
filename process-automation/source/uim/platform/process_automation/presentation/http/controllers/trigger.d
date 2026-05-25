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

class TriggerController : ManageController {
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            CreateTriggerRequest r;
            r.tenantId = tenantId;
            r.processId = ProcessId(j.getString("processId"));
            r.triggerId = TriggerId(j.getString("id"));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.cronExpression = j.getString("cronExpression");
            r.eventType = j.getString("eventType");
            r.eventSource = j.getString("eventSource");
            r.filterExpression = j.getString("filterExpression");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = triggerUsecase.createTrigger(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Trigger created");

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

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = req.getTenantId;

            auto id = TriggerId(extractIdFromPath(req.requestURI.to!string));
            auto t = triggerUsecase.getTrigger(tenantId, id);
            if (t.isNull) {
                writeError(res, 404, "Trigger not found");
                return;
            }

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

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            UpdateTriggerRequest r;
            r.tenantId = tenantId;
            r.triggerId = TriggerId(extractIdFromPath(req.requestURI.to!string));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.cronExpression = j.getString("cronExpression");
            r.eventType = j.getString("eventType");
            r.filterExpression = j.getString("filterExpression");

            auto result = triggerUsecase.updateTrigger(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Trigger updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto id = TriggerId(extractIdFromPath(req.requestURI.to!string));
            auto result = triggerUsecase.deleteTrigger(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Trigger deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
