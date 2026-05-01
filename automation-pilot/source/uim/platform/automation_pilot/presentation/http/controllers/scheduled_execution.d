/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.scheduled_execution;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ScheduledExecutionController : PlatformController {
    private ManageScheduledExecutionsUseCase uc;

    this(ManageScheduledExecutionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/automation-pilot/scheduled-executions", &handleList);
        router.get("/api/v1/automation-pilot/scheduled-executions/*", &handleGet);
        router.post("/api/v1/automation-pilot/scheduled-executions", &handleCreate);
        router.put("/api/v1/automation-pilot/scheduled-executions/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/scheduled-executions/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.scheduledExecutionToJson();
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(ScheduledExecutionId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Scheduled execution not found"); return; }
            res.writeJsonBody(e.scheduledExecutionToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ScheduledExecutionDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.commandId = j.getString("commandId");
            dto.cronExpression = j.getString("cronExpression");
            dto.scheduledAt = j.getString("scheduledAt");
            dto.inputValues = j.getString("inputValues");
            dto.description = j.getString("description");
            dto.maxRetries = j.getString("maxRetries");
            dto.retryDelay = j.getString("retryDelay");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Scheduled execution created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            ScheduledExecutionDTO dto;
            dto.id = extractIdFromPath(path);
            dto.cronExpression = j.getString("cronExpression");
            dto.scheduledAt = j.getString("scheduledAt");
            dto.description = j.getString("description");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Scheduled execution updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(ScheduledExecutionId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Scheduled execution deleted");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
