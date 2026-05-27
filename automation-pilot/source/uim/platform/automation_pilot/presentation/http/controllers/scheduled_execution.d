/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.scheduled_execution;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ScheduledExecutionController : ManageController {
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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto items = scheduledExecutions.listScheduledExecutions(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Scheduled executions retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = ScheduledExecutionId(precheck.id);

            auto e = scheduledExecutions.getScheduledExecution(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Scheduled execution not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto data = precheck.data;
            ScheduledExecutionDTO dto;
            dto.tenantId = tenantId;
            dto.scheduledExecutionId = ScheduledExecutionId(precheck.id);
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
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Scheduled execution created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            
            ScheduledExecutionDTO dto;
            dto.tenantId = tenantId;
            dto.scheduledExecutionId = ScheduledExecutionId(precheck.id);
            dto.cronExpression = data.getString("cronExpression");
            dto.scheduledAt = data.getLong("scheduledAt");
            dto.description = data.getString("description");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = scheduledExecutions.updateScheduledExecution(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Scheduled execution updated");

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
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = ScheduledExecutionId(precheck.id);

            auto result = scheduledExecutions.deleteScheduledExecution(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Scheduled execution deleted successfully");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
