/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.execution;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ExecutionController : PlatformController {
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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = executions.list();
            auto jarr = items.map!(e => e.executionToJson()).array;
            
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
            auto e = executions.getById(ExecutionId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Execution not found"); return; }
            res.writeJsonBody(e.executionToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ExecutionDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.commandId = j.getString("commandId");
            dto.inputValues = j.getString("inputValues");
            dto.triggeredBy = j.getString("triggeredBy");
            dto.createdBy = j.getString("createdBy");

            auto result = executions.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Execution created");

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
            ExecutionDTO dto;
            dto.id = extractIdFromPath(path);

            auto result = executions.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Execution updated");

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
            auto result = executions.remove(ExecutionId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Execution deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
