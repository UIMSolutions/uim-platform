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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = scheduledExecutions.list();
            auto jarr = items.map!(e => e.scheduledExecutionToJson()).array;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Scheduled executions retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = ScheduledExecutionId(extractIdFromPath(path));
            auto e = scheduledExecutions.getById(id);
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
            dto.tenantId = req.getTenantId;
            dto.id = j.getString("id");
            dto.commandId = j.getString("commandId");
            dto.cronExpression = j.getString("cronExpression");
            dto.scheduledAt = j.getString("scheduledAt");
            dto.inputValues = j.getString("inputValues");
            dto.description = j.getString("description");
            dto.maxRetries = j.getString("maxRetries");
            dto.retryDelay = j.getString("retryDelay");
            dto.createdBy = j.getString("createdBy");

            auto result = scheduledExecutions.create(dto);
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
            dto.id = ScheduledExecutionId(extractIdFromPath(path));
            dto.cronExpression = j.getString("cronExpression");
            dto.scheduledAt = j.getString("scheduledAt");
            dto.description = j.getString("description");
            dto.updatedBy = j.getString("updatedBy");

            auto result = scheduledExecutions.update(dto);
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
            auto id = ScheduledExecutionId(extractIdFromPath(path));
            auto result = scheduledExecutions.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Scheduled execution deleted successfully");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
